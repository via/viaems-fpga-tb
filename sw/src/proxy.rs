use futures_lite::future::{block_on, zip};
use nusb::transfer::{Control, RequestBuffer};

async fn do_exchange() {
    let deviceinfo = nusb::list_devices()
        .unwrap()
        .find(|d| d.vendor_id() == 0x1209 && d.product_id() == 0x2041)
        .expect("Unable to find device");

    let device = deviceinfo.open().unwrap();

    let interface = device.detach_and_claim_interface(1).unwrap();

    loop {
        let resp = interface.bulk_in(0x81, RequestBuffer::new(512)).await;
        println!("Got {} bytes", resp.data.len());
    }
}

pub fn main() -> () {
    block_on(do_exchange());
}
