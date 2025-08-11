use futures_lite::future::{block_on, zip};
use nusb::transfer::{Control, RequestBuffer};
use std::time::{Duration, Instant};

use crate::proto::{DeviceCommand, DeviceResponse};

const FTDI_A_INTERFACE: u8 = 0;
const FTDI_A_INDEX: u16 = 1;
const FTDI_A_IN_EP: u8 = 0x81;
const FTDI_A_OUT_EP: u8 = 0x02;
const FTDI_VID: u16 = 0x0403;
const FTDI_PID: u16 = 0x6010;

pub fn do_exchange(commands: Vec<DeviceCommand>) -> Vec<DeviceResponse> {
    let deviceinfo = nusb::list_devices()
        .unwrap()
        .find(|d| d.vendor_id() == FTDI_VID && d.product_id() == FTDI_PID)
        .expect("Unable to find device");

    let device = deviceinfo.open().unwrap();

    let ftdi_a = device.detach_and_claim_interface(FTDI_A_INTERFACE).unwrap();

    // Issue a reset
    ftdi_a
        .control_out_blocking(
            Control {
                control_type: nusb::transfer::ControlType::Vendor,
                recipient: nusb::transfer::Recipient::Device,
                request: 0x0B, // bitmode
                value: 0x00ff, // reset
                index: FTDI_A_INDEX,
            },
            &[],
            Duration::from_millis(100),
        )
        .unwrap();

    // SYNC Fifo mode
    ftdi_a
        .control_out_blocking(
            Control {
                control_type: nusb::transfer::ControlType::Vendor,
                recipient: nusb::transfer::Recipient::Device,
                request: 0x0B, // bitmode
                value: 0x40ff, // fifo mode
                index: FTDI_A_INDEX,
            },
            &[],
            Duration::from_millis(100),
        )
        .unwrap();

    // Set CTS/RTS Flow control
    ftdi_a
        .control_out_blocking(
            Control {
                control_type: nusb::transfer::ControlType::Vendor,
                recipient: nusb::transfer::Recipient::Device,
                request: 0x02, // Set Flow Control
                value: 0,
                index: 0x100 | FTDI_A_INDEX, // (1 << 8) is RTS/CTS
            },
            &[],
            Duration::from_millis(100),
        )
        .unwrap();

    let cmd_duration_ticks = commands.iter().map(|x| x.delay()).sum::<u32>();
    let cmd_duration = Duration::from_nanos(1000 * cmd_duration_ticks as u64 / 15);

    println!(
        "Executing {} commands over {:.1?}...",
        commands.len(),
        cmd_duration
    );
    let mut buffer: Vec<u8> = vec![];

    let read_complete_time = Instant::now() + cmd_duration + Duration::from_secs(1);
    let mut results: Vec<DeviceResponse> = vec![];

    let readloop = async {
        while Instant::now() < read_complete_time {
            let resp = ftdi_a.bulk_in(FTDI_A_IN_EP, RequestBuffer::new(512)).await;
            buffer.extend_from_slice(&resp.data[2..]); // Status bytes??
            while buffer.len() >= 6 {
                if let Some(cmd) = DeviceResponse::parse(&buffer) {
                    results.push(cmd);
                    buffer.drain(0..6);
                } else {
                    buffer.remove(0);
                }
            }
        }
    };

    let writeloop = async {
        for chunk in commands.chunks(128) {
            let mut buffer: Vec<u8> = vec![];
            chunk
                .iter()
                .map(|c| c.encode())
                .for_each(|c| buffer.extend_from_slice(&c));

            ftdi_a.bulk_out(FTDI_A_OUT_EP, buffer).await.status.unwrap();
        }
    };

    block_on(zip(writeloop, readloop));

    results
}
