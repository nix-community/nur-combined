//! Link-time settings for the wasm module.

fn main() {
    // The module's shadow stack. The linker's default is 1 MiB, which a
    // recursive `@function` exhausted at about 170 levels. Overflowing it trapped
    // with "memory access out of bounds" and left the instance unusable for
    // every later compile (#308). A compile now stops at `STACK_LIMIT` in
    // src/lib.rs with a `Stack Overflow` error, which has to stay below this
    // with room for the frames above the compile. 4 MiB reaches about the
    // depth dart-sass does (500 levels of function recursion).
    //
    // Set here rather than in `.cargo/config.toml` because CI exports
    // `RUSTFLAGS`, which replaces config-file rustflags entirely.
    if std::env::var("CARGO_CFG_TARGET_FAMILY").as_deref() == Ok("wasm") {
        println!("cargo:rustc-link-arg-cdylib=-zstack-size={}", 4 << 20);
    }
    println!("cargo:rerun-if-changed=build.rs");
}
