//! Concurrency regression test for the scoped bump arena's global region
//! registry: many threads compile under the live `ScopedAlloc` at once, so
//! each registers its own arena region and every `dealloc` classifies
//! pointers against the shared (relaxed-atomic, write-once) registry while
//! other threads are registering and bump-allocating. Each result must be
//! byte-identical to the single-threaded one.

use sasso::{compile, Options};

#[global_allocator]
static GLOBAL: sasso::ScopedAlloc = sasso::ScopedAlloc;

const SRC: &str = "\
@use \"sass:math\";
$gutter: 12px;
@mixin pad($n) { padding: $n * $gutter; }
.grid {
  width: math.div(100%, 3);
  @include pad(2);
  &:hover { color: rgba(10, 20, 30, 0.5); }
  .cell, .cap {
    margin: 1px + 2px;
    @for $i from 1 through 4 { &.s#{$i} { flex: $i; } }
  }
}
";

#[test]
fn concurrent_compiles_share_the_region_registry() {
    let expected = compile(SRC, &Options::default()).expect("single-threaded compile");
    let threads: Vec<_> = (0..8)
        .map(|_| {
            let expected = expected.clone();
            std::thread::spawn(move || {
                for _ in 0..200 {
                    let out = compile(SRC, &Options::default()).expect("threaded compile");
                    assert_eq!(out, expected, "threaded result diverged");
                }
            })
        })
        .collect();
    for t in threads {
        t.join().expect("compile thread panicked");
    }
}

/// A warn handler that RETAINS what it is handed (here: appends every
/// `formatted` block to one growing `String`) must see intact data afterwards.
/// The handler runs inside the compile's arena scope, so without the library
/// pausing the arena around it, the `String`'s reallocations would come from
/// the arena and dangle once the scope resets — showing up as garbled or
/// cross-contaminated warnings, most visibly when several threads compile at
/// once. Regression test for the CLI's ordered, buffered diagnostics.
#[test]
fn warn_handler_may_retain_event_data_under_the_arena() {
    use std::cell::RefCell;
    use std::rc::Rc;

    let handles: Vec<_> = (0..8)
        .map(|t| {
            std::thread::spawn(move || {
                let mut expected = String::new();
                let mut src = String::new();
                for i in 0..40 {
                    let pad = "x".repeat(i * 7);
                    src.push_str(&format!("@warn \"thread {t} warning {i:02} {pad}\";\n"));
                    expected.push_str(&format!("WARNING: thread {t} warning {i:02} {pad}\n\n"));
                }
                src.push_str("a { b: c }\n");
                let log = Rc::new(RefCell::new(String::new()));
                let sink = Rc::clone(&log);
                let opts = Options::default().with_warn_handler(Rc::new(move |ev: &sasso::WarnEvent<'_>| {
                    // `formatted` carries the frame block; keep only the header
                    // line so the expectation stays simple.
                    let header = ev.formatted.lines().next().unwrap_or("");
                    let mut s = sink.borrow_mut();
                    s.push_str(header);
                    s.push_str("\n\n");
                }));
                for _ in 0..5 {
                    log.borrow_mut().clear();
                    let css = compile(&src, &opts).expect("compile");
                    assert_eq!(css, "a {\n  b: c;\n}");
                    assert_eq!(
                        *log.borrow(),
                        expected,
                        "thread {t}: retained warnings are intact"
                    );
                }
            })
        })
        .collect();
    for h in handles {
        h.join().expect("thread panicked");
    }
}

/// A warn handler may itself call `compile` (an embedder that formats the
/// warning with Sass, or a logger that compiles a template). That nested
/// compile runs while the outer one is paused around the handler; it must nest
/// under the outer arena scope, not reset the arena the outer evaluator is
/// still using. Regression test for `arena::pause` keeping the scope depth.
#[test]
fn warn_handler_may_run_a_nested_compile() {
    use std::cell::RefCell;
    use std::rc::Rc;

    let handles: Vec<_> = (0..4)
        .map(|t| {
            std::thread::spawn(move || {
                let mut src = String::new();
                for i in 0..30 {
                    src.push_str(&format!("$v{i}: {i}px;\n@warn \"w{i}\";\n"));
                }
                src.push_str(".out {\n");
                for i in 0..30 {
                    src.push_str(&format!("  p{i}: $v{i};\n"));
                }
                src.push_str("}\n");
                let mut expected = String::from(".out {\n");
                for i in 0..30 {
                    expected.push_str(&format!("  p{i}: {i}px;\n"));
                }
                expected.push('}');

                let nested_results = Rc::new(RefCell::new(Vec::new()));
                let sink = Rc::clone(&nested_results);
                let opts = Options::default().with_warn_handler(Rc::new(move |ev: &sasso::WarnEvent<'_>| {
                    // Compile something substantial inside the handler so the
                    // nested scope allocates plenty.
                    let nested_src = format!(
                        "$m: \"{}\";\n@for $i from 1 through 40 {{ .n-#{{$i}} {{ w: $i * 2px; m: $m; }} }}\n",
                        ev.message
                    );
                    let css = compile(&nested_src, &Options::default()).expect("nested compile");
                    sink.borrow_mut().push(css.len());
                }));
                for _ in 0..3 {
                    nested_results.borrow_mut().clear();
                    let css = compile(&src, &opts).expect("outer compile");
                    assert_eq!(
                        css, expected,
                        "thread {t}: outer result intact after nested compiles"
                    );
                    assert_eq!(nested_results.borrow().len(), 30);
                }
            })
        })
        .collect();
    for h in handles {
        h.join().expect("thread panicked");
    }
}

/// A host function (`Options::with_function`) that RETAINS what it is handed —
/// its serialized arguments and the bytes it returned — must see intact data
/// afterwards, like a warn handler. The callback runs inside the compile's
/// arena scope; without the library pausing the arena around it, the copies
/// it keeps would be arena-allocated and dangle once the scope resets, showing
/// up as garbled bytes on the next compile. Regression test for the pause
/// around the host callback.
#[test]
fn host_function_may_retain_its_bytes_under_the_arena() {
    use std::cell::RefCell;
    use std::rc::Rc;

    // Wire format: a `u32` argument count, then each value as a tag byte and
    // payload; a string is tag 3, a quoted flag, a `u32` length, UTF-8.
    fn string_value(quoted: bool, text: &str) -> Vec<u8> {
        let mut v = vec![3u8, quoted as u8];
        v.extend_from_slice(&(text.len() as u32).to_le_bytes());
        v.extend_from_slice(text.as_bytes());
        v
    }
    fn one_arg(value: Vec<u8>) -> Vec<u8> {
        let mut v = 1u32.to_le_bytes().to_vec();
        v.extend(value);
        v
    }

    let handles: Vec<_> = (0..4)
        .map(|t| {
            std::thread::spawn(move || {
                const N: usize = 40;
                let mut src = String::from(".out {\n");
                let mut expected_css = String::from(".out {\n");
                let mut expected_inputs = Vec::new();
                for i in 0..N {
                    let text = format!("thread {t} value {i:02} {}", "y".repeat(i * 5));
                    src.push_str(&format!("  p{i}: echo(\"{text}\");\n"));
                    expected_css.push_str(&format!("  p{i}: {text};\n"));
                    expected_inputs.push(one_arg(string_value(true, &text)));
                }
                src.push('}');
                expected_css.push('}');
                // Everything the callback saw and produced, kept across calls
                // and across compiles.
                type Retained = Vec<(Vec<u8>, Vec<u8>)>;
                let retained: Rc<RefCell<Retained>> = Rc::new(RefCell::new(Vec::new()));
                let sink = Rc::clone(&retained);
                let opts = Options::default().with_function(
                    "echo($s)",
                    Rc::new(move |bytes: &[u8]| {
                        // Unquote: return the same text as an unquoted string.
                        let len = u32::from_le_bytes([bytes[6], bytes[7], bytes[8], bytes[9]]) as usize;
                        let text = std::str::from_utf8(&bytes[10..10 + len]).map_err(|e| e.to_string())?;
                        let out = string_value(false, text);
                        sink.borrow_mut().push((bytes.to_vec(), out.clone()));
                        Ok(out)
                    }),
                );
                for _ in 0..5 {
                    retained.borrow_mut().clear();
                    let css = compile(&src, &opts).expect("compile");
                    assert_eq!(css, expected_css, "thread {t}: output intact");
                    let seen = retained.borrow();
                    assert_eq!(seen.len(), N);
                    for (i, (input, output)) in seen.iter().enumerate() {
                        assert_eq!(
                            *input, expected_inputs[i],
                            "thread {t}: retained input {i} intact"
                        );
                        let text = format!("thread {t} value {i:02} {}", "y".repeat(i * 5));
                        assert_eq!(
                            *output,
                            string_value(false, &text),
                            "thread {t}: retained output {i} intact"
                        );
                    }
                }
            })
        })
        .collect();
    for h in handles {
        h.join().expect("thread panicked");
    }
}
