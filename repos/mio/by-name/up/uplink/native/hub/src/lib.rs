//! This `hub` crate is the
//! entry point of the Rust logic.

mod actors;
mod signals;

use actors::run_upload_actor;
use rinf::{dart_shutdown, write_interface};
use tokio::spawn;

// Uncomment below to target the web.
// use tokio_with_wasm::alias as tokio;

write_interface!();

// You can go with any async library, not just `tokio`.
#[tokio::main(flavor = "current_thread")]
async fn main() {
  spawn(run_upload_actor());

  // Keep the main function running until Dart shutdown.
  dart_shutdown().await;
}
