//! Minimal embedding example: `cargo run --example compile`.

use sasso::{compile, Options, OutputStyle};

fn main() {
    let scss = r#"
        $brand: #336699;
        .button {
            color: $brand;
            &:hover { color: lighten($brand, 10%); }
        }
    "#;

    let expanded = compile(scss, &Options::default()).expect("compile");
    println!("/* expanded */\n{expanded}");

    let compressed = compile(scss, &Options::default().with_style(OutputStyle::Compressed)).expect("compile");
    println!("/* compressed */\n{compressed}");
}
