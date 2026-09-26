//! Concurrency-isolation check for the scoped bump arena (perf #5).
//!
//! Installs [`sasso::ScopedAlloc`] as the global allocator, then spawns N
//! threads that each call `sasso::compile` many times concurrently and assert
//! every result is byte-identical to a single-threaded reference. Because each
//! thread keeps its own thread-local arena (a compile is `!Send`), the threads'
//! arenas must never interfere; a corrupt or shared arena would surface as a
//! wrong/garbled output here.
//!
//! Run with: `cargo run --release --example arena_concurrency`

use std::sync::Arc;
use std::thread;

use sasso::{compile, Options};

#[global_allocator]
static GLOBAL: sasso::ScopedAlloc = sasso::ScopedAlloc;

const SOURCES: &[&str] = &[
    "$c: #336699;\n.a { color: $c; .b { color: lighten($c, 10%); } &:hover { color: mix($c, white, 50%); } }",
    "@function double($n) { @return $n * 2; }\n@for $i from 1 through 20 { .c#{$i} { w: double($i) * 1px; } }",
    "@mixin box($p, $c: blue) { padding: $p; color: $c; }\n.x { @include box(4px); }\n.y { @include box(8px, red); }",
    ".grid { @each $n in a, b, c, d { .col-#{$n} { content: \"#{$n}\"; } } }",
];

fn main() {
    let threads = 8usize;
    let iters = 2000usize;

    // Single-threaded reference outputs (also produced under ScopedAlloc).
    let reference: Arc<Vec<String>> = Arc::new(
        SOURCES
            .iter()
            .map(|src| compile(src, &Options::default()).expect("reference compile"))
            .collect(),
    );

    let mut handles = Vec::new();
    for t in 0..threads {
        let reference = Arc::clone(&reference);
        handles.push(thread::spawn(move || {
            for i in 0..iters {
                let idx = (t + i) % SOURCES.len();
                let got =
                    compile(SOURCES[idx], &Options::default()).expect("threaded compile should succeed");
                assert_eq!(
                    got, reference[idx],
                    "thread {t} iter {i}: output diverged from the reference (arena interference?)"
                );
            }
        }));
    }
    for h in handles {
        h.join().expect("worker thread panicked");
    }

    println!(
        "concurrency OK: {threads} threads x {iters} compiles each = {} compiles, all byte-identical",
        threads * iters
    );
}
