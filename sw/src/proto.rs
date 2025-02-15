use std::fs::File;
use std::io::{self, Write, BufRead, prelude::*};

#[derive(Debug)]
pub enum DeviceResponse {
    OutputChanged { delay: u32, outputs: u32 },
}

impl DeviceResponse {
    pub fn parse(bytes: &[u8]) -> Option<Self> {
        if bytes.len() < 6 {
            return None;
        }
        if ((bytes[0] & 0xE0) == 0xC0) &&
            ((bytes[1] & 0x80) == 0x00) &&
            ((bytes[2] & 0x80) == 0x00) &&
            ((bytes[3] & 0x80) == 0x00) &&
            ((bytes[4] & 0x80) == 0x00) &&
            ((bytes[5] & 0x80) == 0x00) {
                return Some(DeviceResponse::OutputChanged {
                    delay: ((bytes[2] as u32 & 0x78) >> 3) |
                           ((bytes[1] as u32 & 0x7F) << 4) |
                           ((bytes[0] as u32 & 0x1F) << 11),

                    outputs: ((bytes[5] as u32 & 0x7F)) |
                        ((bytes[4] as u32 & 0x7F) << 7) |
                        ((bytes[3] as u32 & 0x7F) << 14) |
                        ((bytes[2] as u32 & 0x07) << 21),
                });
        }

        None
    }
}

#[derive(Debug)]
pub enum DeviceCommand {
    Delay(u32),
    Output{delay: u32, outputs: u8 },
    Adc{sel: u8, adc1: u16, adc2: u16},
}

impl DeviceCommand {
    const MAX_DELAY : usize = usize::pow(2, 25) - 1;

    pub fn delay(&self) -> u32 {
        match self {
            DeviceCommand::Delay(delay) => delay + 1,
            DeviceCommand::Output { delay, .. } => delay + 1,
            DeviceCommand::Adc {..} => 1,
        }
    }

    pub fn encode(&self) -> [u8; 4] {
        match self {
            DeviceCommand::Delay(delay) => {[
                (0xD0 | ((delay & 0x01e00000) >> 21)) as u8,
                ((delay & 0x001fc000) >> 14) as u8,
                ((delay & 0x00003f80) >> 7) as u8,
                (delay & 0x7f) as u8,
            ]},
            DeviceCommand::Output { delay, outputs } => {[
                (0xC0 | ((delay & 0x0001e000) >> 13)) as u8,
                ((delay & 0x00001fc0) >> 6) as u8,
                ((delay & 0x0000003f) << 1) as u8 | ((outputs & 0x80) >> 7) as u8,
                (outputs & 0x7f) as u8,
            ]},
            DeviceCommand::Adc { sel, adc1, adc2 } => {[
                (0x80 | (sel << 3)) as u8 | (adc1 >> 9) as u8,
                ((adc1 >> 2) & 0x7f) as u8,
                ((adc1 & 0x3) << 5) as u8 | (adc2 >> 7) as u8,
                (adc2 & 0x7f) as u8,
            ]},

        }

    }
}

// Parse lines of a scenario input file. The time delays represent a delay prior to the action,
// whereas the test bench hardware uses a time delay *after* the action.  Additionally, the
// scenario does not consider time to implement an action, which ranges from 1 cycle to 8 cycles
// (if all ADC inputs change).
pub fn parse_scenario_inputs(file: File) -> Vec<DeviceCommand> {
    let mut line = String::new();
    let mut reader = io::BufReader::new(file);
    let mut adc_values = [0 as f64; 16];
    let mut accumulated_delay = 0;
    let mut commands : Vec<DeviceCommand> = vec![];

    let mut current_time = 0;
    let mut last_command_time = 0;

    while reader.read_line(&mut line).unwrap() != 0 {
        let tokens : Vec<&str> = line.split_whitespace().collect();
        match tokens[0] {
            "a" => { 
                let cmd_delay : usize = (tokens[1].parse::<f64>().unwrap() * (15.0 / 4.0)) as usize;
                let cmd_adc : Vec<f64> = tokens[2..].iter().map(|t| t.parse().unwrap()).collect();

                // Iterate through pairs of adc values
                let mut this_commands = vec![];
                for sel in 0..7 {
                    if cmd_adc[sel*2..sel*2+2] != adc_values[sel*2..sel*2+2] {
                        let adc1 : u16 = ((cmd_adc[sel * 2] / 5.0) * 4095.0) as u16;
                        let adc2 : u16 = ((cmd_adc[sel * 2 + 1] / 5.0) * 4095.0) as u16;

                        let sel = sel as u8;
                        this_commands.push(DeviceCommand::Adc{sel, adc1, adc2});
                    }
                }

                let delay_from_tb_cmds = this_commands.len();
                // If delay is greater than can be stored in a single ADC,
                // generate delay commands. If delay is less than the number of commands
                // , we need to borrow from next command,
                // and if that one is also zero then we cannot actually manifest it

                if this_commands.len() > 0 {
                    let mut remaining_delay = cmd_delay + accumulated_delay;
                    accumulated_delay = 0;
                    if cmd_delay < delay_from_tb_cmds {
                        panic!("Unrealizable command, delay too low");
                    }
                    while remaining_delay > delay_from_tb_cmds {
                        let this_delay = std::cmp::min(remaining_delay, DeviceCommand::MAX_DELAY);
                        commands.push(DeviceCommand::Delay((this_delay - 1) as u32));
                        remaining_delay -= this_delay;
                    }
                    commands.append(&mut this_commands);
                    adc_values.copy_from_slice(cmd_adc.as_slice());
                } else {
                    accumulated_delay += cmd_delay;
                }
            },
            "t" => {
                let cmd_delay : usize = (tokens[1].parse::<f64>().unwrap() * (15.0 / 4.0)) as usize;
                let this_triggers : u8 = if tokens[2].parse::<u8>().unwrap() == 0 { 5 } else { 10 };

                let mut remaining_delay = accumulated_delay + cmd_delay;

                // We need a rising and falling edge, minimum two cycles
                if remaining_delay < 2 {
                    panic!("Bad Trigger delay!");
                }
                remaining_delay -= 2;

                while remaining_delay > 0 {
                    let this_delay = std::cmp::min(remaining_delay, DeviceCommand::MAX_DELAY);
                    commands.push(DeviceCommand::Delay((this_delay - 1) as u32));
                    remaining_delay -= this_delay;
                }
                // MSB is NRST, always keep it high
                commands.push(DeviceCommand::Output{delay: 0, outputs: 0x80 | this_triggers});
                commands.push(DeviceCommand::Output{delay: 0, outputs: 0x80});
                accumulated_delay = 0;
            },
            _ => { },
        }
        line.clear();
    }

    commands
}

#[derive(Debug)]
pub struct OutputChange {
    pub time: u32,
    pub outputs: u32,
}

pub fn collapse_outputs(responses: Vec<DeviceResponse>) -> Vec<OutputChange> {
    let mut values = 0;
    let mut time = 0;
    let mut result = vec![];
    for resp in responses {
        if let DeviceResponse::OutputChanged { delay, outputs } = resp {
            time += delay;
            if outputs != values {
                values = outputs;
                result.push(OutputChange{time, outputs});
            }
        }
    }

    result
}
