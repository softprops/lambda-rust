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
    let reader = Reader::from_path(&Path::new("/dev/null")).expect("Cannot read BAM file");
    dbg!(reader);

    Ok(event)
}
