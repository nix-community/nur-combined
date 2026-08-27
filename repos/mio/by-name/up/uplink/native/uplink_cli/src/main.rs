use clap::{Parser, Subcommand};
use std::fs;
use std::path::PathBuf;
use uplink_core::{upload_text, upload_file};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Upload a text string
    Text {
        /// The text content to upload
        content: String,
    },
    /// Upload a file
    File {
        /// Path to the file to upload
        path: PathBuf,
    },
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Text { content } => {
            match upload_text(content, None).await {
                Ok(url) => println!("Uploaded successfully: {}", url),
                Err(e) => eprintln!("Failed to upload text: {}", e),
            }
        }
        Commands::File { path } => {
            if !path.exists() {
                eprintln!("File not found: {}", path.display());
                return;
            }
            
            let filename = path.file_name()
                .map(|n| n.to_string_lossy().into_owned())
                .unwrap_or_else(|| "file.bin".to_string());
                
            let data = match fs::read(path) {
                Ok(bytes) => bytes,
                Err(e) => {
                    eprintln!("Failed to read file: {}", e);
                    return;
                }
            };
            
            match upload_file(filename, data, None).await {
                Ok(url) => println!("Uploaded successfully: {}", url),
                Err(e) => eprintln!("Failed to upload file: {}", e),
            }
        }
    }
}
