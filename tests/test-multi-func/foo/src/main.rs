use lambda_runtime::{Error, Context};
use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(lambda_runtime::handler_fn(handler)).await?;
    Ok(())
}

async fn handler(
    event: Value,
    _: Context,
) -> Result<Value, Error> {
    Ok(event)
}