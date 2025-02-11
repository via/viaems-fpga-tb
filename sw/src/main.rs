use std::fs::File;
use std::io::Write;
use clap::Parser;

mod proto;
mod usb;

#[derive(Parser)]
struct Cli {
  scenario: String,
  output: String,
}

fn main() {

    let args = Cli::parse();
    let inputs = proto::parse_scenario_inputs(File::open(args.scenario).unwrap());

    let result = usb::do_exchange(inputs);
    let collapsed_results = proto::collapse_outputs(result);

    println!("{} changes detected", collapsed_results.len());

    let mut output_file = File::create(args.output).unwrap();
    for c in collapsed_results {
        writeln!(output_file, "# OUTPUTS {} {:x}", c.time, c.outputs).unwrap();
    }

    
}
