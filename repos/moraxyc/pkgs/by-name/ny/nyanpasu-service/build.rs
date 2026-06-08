use rustc_version::version_meta;
use std::env;

fn main() {
    println!("cargo:rustc-env=COMMIT_HASH=@COMMIT_HASH@");
    println!("cargo:rustc-env=COMMIT_AUTHOR=github-actions[bot]");
    println!("cargo:rustc-env=COMMIT_DATE=@COMMIT_DATE@T00:00:00Z");
    println!("cargo:rustc-env=BUILD_DATE=@COMMIT_DATE@T00:00:00Z");

    println!(
        "cargo:rustc-env=BUILD_PROFILE={}",
        match env::var("PROFILE").unwrap().as_str() {
            "release" => "Release",
            "debug" => "Debug",
            _ => "Unknown",
        }
    );

    println!("cargo:rustc-env=BUILD_PLATFORM={}", env::var("TARGET").unwrap());

    let rustc_version = version_meta().unwrap();
    println!(
        "cargo:rustc-env=RUSTC_VERSION={}",
        rustc_version.short_version_string
    );
    println!(
        "cargo:rustc-env=LLVM_VERSION={}",
        match rustc_version.llvm_version {
            Some(v) => v.to_string(),
            None => "Unknown".to_string(),
        }
    );
}
