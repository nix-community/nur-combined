//! Allocation bounds for builtins that build a new string or list from old ones.
//!
//! A string or list value is an immutable shared buffer (`Rc<str>`,
//! `Rc<[Value]>`). The cheap way to build one is to borrow the inputs and fill
//! the result once. The expensive way is to copy every input into a `String` or
//! `Vec`, grow that, and then copy it again into the `Rc`. Both produce the
//! same CSS, so only allocation counting can tell them apart.
//!
//! Every test compares the bytes allocated during a compile with the largest
//! single allocation, which is the final result's buffer. That keeps the bounds
//! independent of `size_of::<Value>()` and of the platform.
//!
//! The counting allocator needs `unsafe`, which the crate denies elsewhere. It
//! is confined to this test binary.
#![allow(unsafe_code)]

use std::alloc::{GlobalAlloc, Layout, System};
use std::cell::Cell;
use std::sync::Mutex;

struct Counting;

thread_local! {
    /// Counting is per thread, so allocations made by the test harness on
    /// other threads are not counted.
    static TRACKING: Cell<bool> = const { Cell::new(false) };
    static TOTAL: Cell<usize> = const { Cell::new(0) };
    static LARGEST: Cell<usize> = const { Cell::new(0) };
}

fn record(size: usize) {
    // `try_with`: the allocator also runs while thread-locals are torn down.
    let _ = TRACKING.try_with(|t| {
        if t.get() {
            TOTAL.with(|c| c.set(c.get() + size));
            LARGEST.with(|c| c.set(c.get().max(size)));
        }
    });
}

unsafe impl GlobalAlloc for Counting {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        record(layout.size());
        System.alloc(layout)
    }
    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        System.dealloc(ptr, layout)
    }
    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        // A grown buffer may be copied to a new block, so count its full size.
        record(new_size);
        System.realloc(ptr, layout, new_size)
    }
}

#[global_allocator]
static ALLOC: Counting = Counting;

/// Serializes the measurements. The counters are per thread, but the
/// harness's own bookkeeping stays out of the way more reliably this way.
static LOCK: Mutex<()> = Mutex::new(());

/// Compile `src` and return the total bytes allocated during the compile,
/// divided by the largest single allocation.
fn alloc_ratio(src: &str) -> f64 {
    let _guard = LOCK.lock().unwrap_or_else(|e| e.into_inner());
    TOTAL.with(|c| c.set(0));
    LARGEST.with(|c| c.set(0));
    TRACKING.with(|t| t.set(true));
    let result = sasso::compile(src, &sasso::Options::default());
    TRACKING.with(|t| t.set(false));
    result.expect("compile");
    let total = TOTAL.with(Cell::get) as f64;
    let largest = LARGEST.with(Cell::get) as f64;
    total / largest
}

/// Doubling a string with `+`: each step should allocate the result twice (an
/// exact-size buffer and the `Rc<str>` it becomes), summing to about 4× the
/// final string over the run. Copying both operands out first and growing an
/// unsized buffer summed to about 7×.
#[test]
fn string_concat_allocates_its_result_once() {
    let ratio = alloc_ratio("$s: a; @for $i from 1 through 22 { $s: $s + $s; } a { b: str-length($s) }");
    assert!(ratio < 5.0, "string + allocated {ratio:.2}x its result");
}

/// Doubling a list with `join`: each step should allocate only the result's
/// `Rc<[Value]>`, summing to about 2× the final list. Copying both inputs into
/// `Vec`s, growing one and copying it into the `Rc` summed to about 6×.
#[test]
fn join_allocates_its_result_once() {
    let ratio = alloc_ratio("$l: a; @for $i from 1 through 16 { $l: join($l, $l); } a { b: length($l) }");
    assert!(ratio < 3.0, "join allocated {ratio:.2}x its result");
}

/// Growing a list with `append` is quadratic in any immutable-list design: step
/// `i` must build an `i`-element list. With N steps that sums to N/2 × the
/// final list. Copying into a `Vec`, growing it by one and copying it into the
/// `Rc` cost about 2× that.
#[test]
fn append_allocates_its_result_once() {
    let n = 1000.0;
    let ratio =
        alloc_ratio("$l: (); @for $i from 1 through 1000 { $l: append($l, $i); } a { b: length($l) }");
    assert!(
        ratio < 0.75 * n,
        "append allocated {ratio:.2}x its result over {n} steps"
    );
}

/// Reading elements with `nth` and `index` borrows the list. Copying the whole
/// list on every call made a loop over a list's elements quadratic.
#[test]
fn nth_and_index_do_not_copy_the_list() {
    // Building the list by doubling costs about 2× its final size; 200 reads
    // that each copied the list added 200× more.
    let ratio = alloc_ratio(
        "$l: a; @for $i from 1 through 14 { $l: join($l, $l); } \
         @for $i from 1 through 100 { $x: nth($l, $i); $y: index($l, b); } a { b: length($l) }",
    );
    assert!(ratio < 3.0, "nth/index allocated {ratio:.2}x the list");
}
