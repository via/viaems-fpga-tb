use std::fs::File;
use std::io::{self, Write, BufRead, prelude::*};

#[derive(Debug)]
pub enum DeviceResponse {
    OutputChanged { delay: u32, outputs: u32 },
    Overflow,
}

impl DeviceResponse {
    pub fn parse(bytes: &[u8]) -> Option<Self> {
        if bytes.len() < 6 {
            return None;
        }
        if bytes[0] == 0xB0 {
            return Some(DeviceResponse::Overflow)
        } else 
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

    pub fn size(&self) -> usize {
        match self {
            Self::OutputChanged { delay: _, outputs: _ } => 6,
            Self::Overflow => 1,
        }
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
    let mut commands : Vec<DeviceCommand> = vec![];

    while reader.read_line(&mut line).unwrap() != 0 {
        let tokens : Vec<&str> = line.split_whitespace().collect();
        match tokens[0] {
            "d" => {
                let delay : u32 = tokens[1].parse().unwrap();
                commands.push(DeviceCommand::Delay(delay));
            },
            "a" => { 
                let sel : u8 = tokens[1].parse().unwrap();
                let adc1 : u16 = tokens[2].parse().unwrap();
                let adc2 : u16 = tokens[3].parse().unwrap();
                commands.push(DeviceCommand::Adc{sel, adc1, adc2});
            },
            "o" => {
                let delay : u32 = tokens[1].parse().unwrap();
                let outputs : u8 = tokens[2].parse().unwrap();
                commands.push(DeviceCommand::Output{delay, outputs});
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
    let mut first_change_occured = false;
    let mut idx = 0;
    for resp in responses {
        if let DeviceResponse::Overflow = resp {
            if first_change_occured {
                panic!("Overflow at time {} idx {}!", time as f64 / 60000000.0, idx);
            }
        }
        idx += 1;
        if let DeviceResponse::OutputChanged { delay, outputs } = resp {
            time += delay + 1;
            if outputs != values {
                values = outputs;
                result.push(OutputChange{time, outputs});
                first_change_occured = true;
            }
        }
    }

    result
}
