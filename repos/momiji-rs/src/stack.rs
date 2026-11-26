//! The stack guard: turn runaway recursion into a compile error.
//!
//! A stylesheet controls how deep the parser and the evaluator recurse: a
//! recursive `@function` or `@mixin`, an `@import` chain, or source nested a few
//! thousand levels deep. Recursing past the end of the native stack aborts the
//! process (natively) or traps and wrecks the instance (wasm), which takes the
//! host down with it. dart-sass reports `Stack Overflow` instead, and so does
//! this.
//!
//! The guard measures stack *bytes*, not recursion depth. One level costs very
//! different amounts depending on what recurses (a function call costs several
//! times a nested rule) and on how sasso was built (a debug frame is many times
//! a release one), so a depth limit would be either too tight for one or unsafe
//! for another. [`enter`] records the stack position where a compile starts;
//! [`check`] compares the current position against it at every recursion point
//! and fails once the compile has used more than its limit.
//!
//! Taking a local's address is safe Rust, so the guard needs no `unsafe`. It
//! assumes the stack grows downward, as it does on every target sasso builds
//! for (x86_64, aarch64, and wasm32's shadow stack). On a stack that grew
//! upward the measured use would stay 0 and the guard would never fire, so
//! that case fails open (no false errors), not closed.

use std::cell::Cell;

use crate::error::Error;

/// dart-sass's wording, so a host that matches on the message sees the same
/// text from either compiler.
pub(crate) const MESSAGE: &str = "Stack Overflow";

/// The limit when the host sets none ([`crate::Options::with_stack_limit`]),
/// on a thread whose stack size is unknown. It has to be safe on the smallest
/// stack a compile commonly runs on: Ruby gives a non-main thread (a Puma
/// worker) 1 MiB in all, and Ruby's own frames sit above sasso's.
pub(crate) const DEFAULT_LIMIT: usize = 768 << 10;

/// The limit when the host sets none on the process's main thread, as Rust's
/// runtime names it. Main-thread stacks are 8 MiB on macOS and on Linux's
/// default `ulimit -s`. This leaves 2 MiB for the frames above the compile and
/// for a smaller `ulimit`.
pub(crate) const MAIN_THREAD_LIMIT: usize = 6 << 20;

thread_local! {
    /// `(base, limit)` of the compile running on this thread; `base == 0`
    /// when none is.
    static GUARD: Cell<(usize, usize)> = const { Cell::new((0, 0)) };
}

/// The address of a local in this frame: the current stack position.
#[inline(always)]
fn position() -> usize {
    let probe = 0u8;
    // `black_box` keeps the local in memory, so its address is a real stack
    // slot rather than one the optimizer is free to invent.
    std::hint::black_box(&probe) as *const u8 as usize
}

/// The limit for a compile that set none, from what this thread is known to be.
pub(crate) fn default_limit() -> usize {
    if std::thread::current().name() == Some("main") {
        MAIN_THREAD_LIMIT
    } else {
        DEFAULT_LIMIT
    }
}

/// Restores the previous guard when the compile that entered it ends.
pub(crate) struct Scope {
    prev: (usize, usize),
}

/// Start guarding a compile that may use `limit` bytes of stack from here.
///
/// A compile nested inside another on the same thread (a custom function or a
/// warn handler that compiles) keeps the outer compile's base and limit: both
/// run on the same stack, and what matters is how much of it is used in all.
pub(crate) fn enter(limit: usize) -> Scope {
    let prev = GUARD.with(Cell::get);
    if prev.0 == 0 {
        GUARD.with(|g| g.set((position(), limit)));
    }
    Scope { prev }
}

impl Drop for Scope {
    fn drop(&mut self) {
        let prev = self.prev;
        GUARD.with(|g| g.set(prev));
    }
}

/// How far past its limit a compile may go before the unpositioned
/// [`check`] fires. A call site that can point at the construct
/// ([`check_at`]) should be the one that reports the overflow, and on most
/// paths it is less than a level away, so the fallback waits this much
/// longer. It must stay well inside the margin every limit leaves below the
/// real stack.
const FALLBACK_SLACK: usize = 64 << 10;

/// Whether the running compile has used more than `limit + slack` bytes.
#[inline]
fn exhausted(slack: usize) -> bool {
    let (base, limit) = GUARD.with(Cell::get);
    base != 0 && base.saturating_sub(position()) > limit.saturating_add(slack)
}

/// Fail with dart-sass's `Stack Overflow`, pointing at `pos` (spanning
/// `length` bytes), once the running compile has used more stack than its
/// limit. Call it where a stylesheet makes sasso recurse and the construct
/// responsible is known: a call, an `@include`, a nested block.
#[inline]
pub(crate) fn check_at(pos: crate::scanner::Pos, length: usize) -> Result<(), Error> {
    if exhausted(0) {
        Err(Error::at(MESSAGE, pos).with_length(length))
    } else {
        Ok(())
    }
}

/// The unpositioned backstop for recursion that passes no [`check_at`]. It
/// fires [`FALLBACK_SLACK`] past the limit, so a positioned check on the same
/// path gets to report first.
#[inline]
pub(crate) fn check() -> Result<(), Error> {
    if exhausted(FALLBACK_SLACK) {
        Err(Error::unpositioned(MESSAGE))
    } else {
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// How much stack the guard had measured when it first failed.
    fn used() -> usize {
        let (base, _) = GUARD.with(Cell::get);
        base.saturating_sub(position())
    }

    thread_local! {
        static FAILED_AT: Cell<usize> = const { Cell::new(0) };
    }

    fn recurse(n: usize) -> Result<usize, Error> {
        if let Err(e) = check() {
            FAILED_AT.with(|f| f.set(used()));
            return Err(e);
        }
        // A frame big enough that the limit is reached quickly.
        let pad = std::hint::black_box([0u8; 512]);
        if n == 0 {
            return Ok(pad[0] as usize);
        }
        Ok(recurse(n - 1)? + 1)
    }

    #[test]
    fn unguarded_code_never_fails() {
        assert!(recurse(50).is_ok());
    }

    #[test]
    fn a_guarded_compile_fails_past_its_limit_and_restores_the_guard() {
        {
            let limit = 64 << 10;
            let _scope = enter(limit);
            let err = recurse(1_000_000).unwrap_err();
            assert_eq!(err.message, MESSAGE);
            // The unpositioned backstop fires past the limit plus its slack,
            // and within a frame of it (each level here is a little over
            // 512 bytes; 4 KiB covers any build's frame overhead).
            let at = FAILED_AT.with(Cell::get);
            assert!(at > limit + FALLBACK_SLACK, "fired at {at}, before limit + slack");
            assert!(
                at < limit + FALLBACK_SLACK + (4 << 10),
                "fired at {at}, well past limit + slack"
            );
            // Shallow recursion within the limit still works.
            assert!(recurse(10).is_ok());
        }
        // The scope is gone, so the guard is off again.
        assert!(recurse(50).is_ok());
        assert_eq!(GUARD.with(Cell::get).0, 0);
    }

    #[test]
    fn a_positioned_check_fires_at_the_limit_itself() {
        let limit = 64 << 10;
        let _scope = enter(limit);
        fn positioned(n: usize) -> Result<usize, Error> {
            if let Err(e) = check_at(crate::scanner::Pos { line: 1, col: 1 }, 0) {
                FAILED_AT.with(|f| f.set(used()));
                return Err(e);
            }
            let pad = std::hint::black_box([0u8; 512]);
            if n == 0 {
                return Ok(pad[0] as usize);
            }
            Ok(positioned(n - 1)? + 1)
        }
        assert!(positioned(1_000_000).is_err());
        let at = FAILED_AT.with(Cell::get);
        assert!(at > limit && at < limit + (4 << 10), "fired at {at}");
    }

    #[test]
    fn a_nested_compile_keeps_the_outer_base() {
        let _outer = enter(64 << 10);
        let outer = GUARD.with(Cell::get);
        {
            let _inner = enter(1 << 30);
            assert_eq!(GUARD.with(Cell::get), outer);
        }
        assert_eq!(GUARD.with(Cell::get), outer);
    }
}
