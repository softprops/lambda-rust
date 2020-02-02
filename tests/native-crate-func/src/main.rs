use std::path::Path;
use lambda_runtime::{error::HandlerError, lambda, Context};
use serde_json::Value;
use rust_htslib::bam::Reader;

fn main() {
    lambda!(handler)
}

fn handler(
    event: Value,
    _: Context,
) -> Result<Value, HandlerError> {
    let reader = Reader::from_path(&Path::new("/dev/null"));
    match reader {
        Ok(_bam) => println!("No biology from /dev/null, report this new life!"),
        Err(_bam) => println!("The world still makes sense, reading from /dev/null does not yield DNA bases :)"),
    };

    Ok(event)
}
