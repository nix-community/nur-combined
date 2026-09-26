//! Tiny CLI wrapper around `grass` for benchmarking.
//!
//! Usage:
//!   grass_runner <file.scss> [more.scss ...]
//!       Compile each file once, print concatenated CSS to stdout.
//!
//!   grass_runner --loop N <file.scss>
//!       Compile <file.scss> N times in a tight in-process loop. Prints the
//!       compiled CSS exactly once (the last iteration) plus a one-line timing
//!       summary to stderr. This measures *pure compile throughput* with zero
//!       process-startup amortization — the in-process advantage we want to
//!       isolate versus a `sass <file>` subprocess.
//!
//!   grass_runner --quiet ...
//!       Suppress CSS on stdout (useful when you only care about timing and
//!       don't want stdout I/O to pollute the measurement).
//!
//! Exit code is non-zero on any compile error.

use std::process::exit;
use std::time::Instant;

fn usage_and_exit() -> ! {
    eprintln!(
        "usage:\n  \
         grass_runner <file.scss> [more.scss ...]\n  \
         grass_runner [--quiet] --loop N <file.scss>\n  \
         grass_runner [--quiet] <file.scss>"
    );
    exit(2);
}

fn compile(path: &str) -> String {
    // Default options: grass resolves @import relative to the input file's
    // directory automatically, matching dart-sass's default load path.
    match grass::from_path(path, &grass::Options::default()) {
        Ok(css) => css,
        Err(e) => {
            eprintln!("grass: error compiling {path}: {e}");
            exit(1);
        }
    }
}

fn main() {
    let mut args: Vec<String> = std::env::args().skip(1).collect();

    // Parse a couple of simple flags. Order: [--quiet] [--loop N] files...
    let mut quiet = false;
    let mut loop_n: Option<u64> = None;

    // Manual flag parsing to keep deps at exactly `grass`.
    let mut i = 0;
    let mut files: Vec<String> = Vec::new();
    while i < args.len() {
        match args[i].as_str() {
            "--quiet" | "-q" => quiet = true,
            "--loop" => {
                i += 1;
                let n = args
                    .get(i)
                    .and_then(|s| s.parse::<u64>().ok())
                    .unwrap_or_else(|| {
                        eprintln!("--loop requires a positive integer N");
                        exit(2);
                    });
                loop_n = Some(n);
            }
            "-h" | "--help" => usage_and_exit(),
            other => files.push(other.to_string()),
        }
        i += 1;
    }
    // Silence unused warning if args is later not needed.
    let _ = &mut args;

    if files.is_empty() {
        usage_and_exit();
    }

    if let Some(n) = loop_n {
        if files.len() != 1 {
            eprintln!("--loop mode takes exactly one file");
            exit(2);
        }
        let path = &files[0];
        let mut last = String::new();
        let start = Instant::now();
        for _ in 0..n {
            // Re-read + recompile every iteration so we measure the full
            // file->CSS pipeline (parse + eval + serialize), matching what a
            // subprocess `sass <file>` does each invocation.
            last = compile(path);
        }
        let elapsed = start.elapsed();
        let per = elapsed.as_secs_f64() / n as f64;
        eprintln!(
            "loop: {n} compiles of {path} in {:.4}s -> {:.3} ms/compile, {:.1} compiles/sec",
            elapsed.as_secs_f64(),
            per * 1000.0,
            1.0 / per
        );
        if !quiet {
            print!("{last}");
        }
        return;
    }

    // One-shot mode: compile each file once, concatenate to stdout.
    let mut out = String::new();
    for path in &files {
        out.push_str(&compile(path));
        out.push('\n');
    }
    if !quiet {
        print!("{out}");
    }
}
