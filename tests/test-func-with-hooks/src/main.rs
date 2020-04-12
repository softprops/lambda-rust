use lambda_runtime::{error::HandlerError, lambda, Context};
use serde_json::Value;
use std::fs::File;
use std::io::Read;

fn main() {
    lambda!(handler)
}

fn handler(
    _event: Value,
    _: Context,
) -> Result<Value, HandlerError> {
    let mut file = File::open("/var/task/output.log").unwrap();
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();
    Ok(contents.split(",").collect())
}