//! rfetch benchmark harness.
//!
//! spawns the release binary N times and reports wall-clock statistics
//! (min / median / mean / p90 / p99 / max / stddev) in milliseconds.
//!
//! this replaces eyeballing `time rfetch`: `time` gives you one noisy sample
//! (including shell startup) while this runs a warmup, many iterations, and
//! reports the distribution so you can tell signal from noise.
//!
//! build + run:
//!   cargo build --release
//!   cargo run --release --example bench
//!   cargo run --release --example bench -- --runs 200
//!   cargo run --release --example bench -- --compare build/rfetch
//!   cargo run --release --example bench -- -- --minimal
//!
//! options:
//!   --runs N          measured iterations per binary   (default 100)
//!   --warmup N        discarded warmup iterations      (default 10)
//!   --bin PATH        binary under test                (default target/release/rfetch)
//!   --compare PATH    second binary; runs are interleaved A/B/A/B to cancel drift
//!   --json            emit one json object per binary
//!   --                everything after is passed to the binary

use std::env;
use std::fmt::Write as _;
use std::process::{Command, Stdio};
use std::time::Instant;

#[derive(Clone)]
struct Stats {
    label: String,
    n: usize,
    min: f64,
    max: f64,
    mean: f64,
    median: f64,
    p90: f64,
    p99: f64,
    stddev: f64,
}

fn summarize(label: &str, mut samples_ns: Vec<u128>) -> Stats {
    samples_ns.sort_unstable();
    let n = samples_ns.len();
    let to_ms = |ns: u128| ns as f64 / 1_000_000.0;

    let sum: u128 = samples_ns.iter().sum();
    let mean_ns = sum as f64 / n as f64;
    let variance = samples_ns
        .iter()
        .map(|&s| {
            let d = s as f64 - mean_ns;
            d * d
        })
        .sum::<f64>()
        / n as f64;

    let pct = |p: f64| -> f64 {
        // nearest-rank percentile, 1-indexed
        let rank = (p / 100.0 * n as f64).ceil() as usize;
        let idx = rank.saturating_sub(1).min(n - 1);
        to_ms(samples_ns[idx])
    };

    Stats {
        label: label.to_string(),
        n,
        min: to_ms(samples_ns[0]),
        max: to_ms(samples_ns[n - 1]),
        mean: to_ms(sum / n as u128),
        median: pct(50.0),
        p90: pct(90.0),
        p99: pct(99.0),
        stddev: variance.sqrt() / 1_000_000.0,
    }
}

fn measure(bin: &str, args: &[String]) -> u128 {
    let start = Instant::now();
    let status = Command::new(bin)
        .args(args)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status();
    let elapsed = start.elapsed().as_nanos();
    match status {
        Ok(s) if s.success() => elapsed,
        Ok(s) => {
            eprintln!("bench: {bin} exited with {s}");
            elapsed
        }
        Err(e) => {
            eprintln!("bench: failed to run {bin}: {e}");
            std::process::exit(1);
        }
    }
}

fn run_binary(label: &str, bin: &str, args: &[String], runs: usize, warmup: usize) -> Stats {
    for _ in 0..warmup {
        measure(bin, args);
    }
    let mut samples = Vec::with_capacity(runs);
    for _ in 0..runs {
        samples.push(measure(bin, args));
    }
    summarize(label, samples)
}

fn print_human(s: &Stats) {
    println!("{}  ({} runs)", s.label, s.n);
    println!("  min    {:>8.3} ms", s.min);
    println!("  median {:>8.3} ms", s.median);
    println!("  mean   {:>8.3} ms  (sd {:.3})", s.mean, s.stddev);
    println!("  p90    {:>8.3} ms", s.p90);
    println!("  p99    {:>8.3} ms", s.p99);
    println!("  max    {:>8.3} ms", s.max);
}

fn print_json(s: &Stats) {
    let mut out = String::new();
    write!(
        out,
        "{{\"label\":\"{}\",\"n\":{},\"min\":{:.6},\"median\":{:.6},\"mean\":{:.6},\"p90\":{:.6},\"p99\":{:.6},\"max\":{:.6},\"stddev\":{:.6}}}",
        s.label, s.n, s.min, s.median, s.mean, s.p90, s.p99, s.max, s.stddev
    )
    .unwrap();
    println!("{out}");
}

fn print_usage() {
    eprintln!(
        "usage: bench [--runs N] [--warmup N] [--bin PATH] [--compare PATH] [--json] [-- BIN_ARGS...]"
    );
}

fn main() {
    let argv: Vec<String> = env::args().skip(1).collect();

    let mut runs = 100usize;
    let mut warmup = 10usize;
    let mut bin: Option<String> = None;
    let mut compare: Option<String> = None;
    let mut json = false;
    let mut bin_args: Vec<String> = Vec::new();

    let mut i = 0;
    while i < argv.len() {
        match argv[i].as_str() {
            "--runs" => {
                i += 1;
                runs = argv.get(i).and_then(|v| v.parse().ok()).unwrap_or_else(|| {
                    eprintln!("bench: --runs needs a number");
                    std::process::exit(1);
                });
            }
            "--warmup" => {
                i += 1;
                warmup = argv.get(i).and_then(|v| v.parse().ok()).unwrap_or_else(|| {
                    eprintln!("bench: --warmup needs a number");
                    std::process::exit(1);
                });
            }
            "--bin" => {
                i += 1;
                bin = argv.get(i).cloned();
            }
            "--compare" => {
                i += 1;
                compare = argv.get(i).cloned();
            }
            "--json" => json = true,
            "--" => {
                bin_args.extend_from_slice(&argv[i + 1..]);
                break;
            }
            "-h" | "--help" => {
                print_usage();
                return;
            }
            other => {
                eprintln!("bench: unknown option {other}");
                print_usage();
                std::process::exit(1);
            }
        }
        i += 1;
    }

    if runs == 0 {
        eprintln!("bench: --runs must be >= 1");
        std::process::exit(1);
    }

    let bin_a = bin.unwrap_or_else(|| "target/release/rfetch".to_string());
    let label_a = bin_a.clone();

    match compare {
        Some(bin_b) => {
            let label_b = bin_b.clone();
            // warm both binaries so page cache, branch predictors and cpu
            // frequency are hot for each regardless of who runs first.
            for _ in 0..warmup {
                measure(&bin_a, &bin_args);
                measure(&bin_b, &bin_args);
            }
            // randomize measurement order: a fixed A-then-B interleave is
            // biased because B always inherits the pages A just warmed. A
            // randomized stream gives both binaries the same distribution of
            // cold-ish vs warm starts, which is what opt-level comparisons
            // hinge on (code size / page warming / fs reads).
            let mut seed: u64 = 0x9E37_79B9_7F4A_7C15;
            let mut next = || {
                seed ^= seed << 13;
                seed ^= seed >> 7;
                seed ^= seed << 17;
                seed
            };
            let mut samples_a = Vec::with_capacity(runs);
            let mut samples_b = Vec::with_capacity(runs);
            for _ in 0..runs * 2 {
                if next() & 1 == 0 {
                    samples_a.push(measure(&bin_a, &bin_args));
                } else {
                    samples_b.push(measure(&bin_b, &bin_args));
                }
            }
            let a = summarize(&label_a, samples_a);
            let b = summarize(&label_b, samples_b);

            if json {
                print_json(&a);
                print_json(&b);
            } else {
                print_human(&a);
                println!();
                print_human(&b);
                println!();
                let delta = b.median - a.median;
                let pct = if a.median > 0.0 {
                    delta / a.median * 100.0
                } else {
                    0.0
                };
                println!(
                    "b vs a (median): {:+.3} ms ({:+.1}%)  [{} -> {}]",
                    delta, pct, a.label, b.label
                );
            }
        }
        None => {
            let s = run_binary(&label_a, &bin_a, &bin_args, runs, warmup);
            if json {
                print_json(&s);
            } else {
                print_human(&s);
            }
        }
    }
}
