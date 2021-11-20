use lambda_runtime::{Error, Context};
use serde_json::Value;
use std::fs::File;
use std::io::Read;

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(lambda_runtime::handler_fn(handler)).await?;
    Ok(())
}

async fn handler(
    _event: Value,
    _: Context,
) -> Result<Value, Error> {
    let mut file = File::open("/var/task/output.log").unwrap();
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();
    Ok(contents.split(",").collect())
}