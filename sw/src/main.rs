use gumdrop::Options;
use std::fs::File;
use std::io::Write;

mod proto;
mod usb;

#[derive(Debug, Options)]
struct Cli {
    help: bool,

    #[options(help = "Scenario text input to submit to test harness")]
    scenario: Option<String>,

    #[options(help = "Output file for received pin events from test harness")]
    output: Option<String>,

    #[options(
        no_short,
        long = "cmd-outputs",
        help = "Submit a single output command"
    )]
    cmd_outputs: Option<String>,
    #[options(help = "Show raw messages received from test harness")]
    trace: bool,

    #[options(help = "Reset FTDI state")]
    reset: bool
}

fn main() {
    let args = Cli::parse_args_default_or_exit();
    if let Some(outputs) = args.cmd_outputs {
        let parsed = u8::from_str_radix(&outputs, 16).unwrap();
        let cmd = proto::DeviceCommand::Output {
            delay: 0,
            outputs: parsed,
        };
        usb::do_exchange(vec![cmd]);
    } else if let Some(scenario) = args.scenario {
        let inputs = proto::parse_scenario_inputs(File::open(scenario).unwrap());

        let result = usb::do_exchange(inputs);
        if args.trace {
            for r in &result {
                println!("{:?}", r);
            }
        }

        let collapsed_results = proto::collapse_outputs(&result);

        println!("{} changes detected", collapsed_results.len());

        if let Some(filename) = args.output {
            let mut output_file = File::create(filename.clone()).unwrap();
            for c in collapsed_results {
                writeln!(output_file, "# OUTPUTS {} {:x}", c.time, c.outputs).unwrap();
            }

            let mut trace_file = File::create(filename + ".trace").unwrap();
            let mut time = 0;
            for c in &result {
                if let proto::DeviceResponse::OutputChanged { delay, outputs } = c {
                    time += delay + 1;
                    writeln!(trace_file, "{} {:x}     {:?}", time, outputs, c).unwrap();
                }
            }
        }
    } else if args.reset {
        usb::reset();
    }
}
