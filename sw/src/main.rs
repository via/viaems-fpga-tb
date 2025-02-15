use std::fs::File;
use std::io::Write;
use clap::Parser;

mod proto;
mod usb;

#[derive(Parser)]
struct Cli {
  #[arg(short, long)]
  scenario: Option<String>,

  #[arg(short, long)]
  output: Option<String>,

  #[arg(long = "cmd-outputs", help="Set outputs to hex value")]
  cmd_outputs: Option<String>,
}

fn main() {

    let args = Cli::parse();
    if let Some(outputs) = args.cmd_outputs {
        let parsed = u8::from_str_radix(&outputs, 16).unwrap();
        let cmd = proto::DeviceCommand::Output{delay: 0, outputs: parsed};
        usb::do_exchange(vec![cmd]);
    } else if let Some(scenario) = args.scenario {
        let inputs = proto::parse_scenario_inputs(File::open(scenario).unwrap());

        let result = usb::do_exchange(inputs);
        let collapsed_results = proto::collapse_outputs(result);

        println!("{} changes detected", collapsed_results.len());

        if let Some(filename) = args.output {
            let mut output_file = File::create(filename).unwrap();
            for c in collapsed_results {
                writeln!(output_file, "# OUTPUTS {} {:x}", c.time, c.outputs).unwrap();
            }
        }
    }
    
}
