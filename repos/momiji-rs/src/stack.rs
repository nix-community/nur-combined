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

/// The limit when the host sets none ([`crate::Options::with_stack_limit`]).
/// sasso cannot learn how big the calling thread's stack is (std has no safe
/// way to ask, and a thread's name proves nothing, #314), so this has to be
/// safe on the smallest stack a compile commonly runs on: Ruby gives a
/// non-main thread (a Puma worker) 1 MiB in all, and Ruby's own frames sit
/// above sasso's. A host that knows its stack is bigger says so.
pub(crate) const DEFAULT_LIMIT: usize = 768 << 10;

/// What one level of a tree built in a loop is charged ([`Chain::level`]). A
/// left-deep chain such as `1 + 1 + …` or `(a: b) and (a: b) and …` is built
/// iteratively, so building it does not grow the stack, but every later walk
/// of the tree (evaluating it, serializing it, writing it into a diagnostic,
/// dropping it) recurses once per level. Charging each level up front bounds
/// all of those walks with the one limit, including walkers added later.
///
/// The figure is the costliest walk measured: evaluating a `+` chain, about
/// 2.3 KiB a level in a release build and 30 KiB in a debug one (2026-11-26,
/// macOS/arm64). Every other walk costs less per level, so a chain too deep
/// to evaluate is also too deep to parse, and nothing that evaluation could
/// have handled is rejected.
pub(crate) const LEVEL_COST: usize = if cfg!(debug_assertions) { 32 << 10 } else { 5 << 9 };

/// What one level of pseudo-class nesting in a selector (`:is(:not(…))`) is
/// charged while it is parsed ([`Chain::level_or_trip`]). Selector text can be
/// assembled at run time (`#{$s}`), so no parser check bounds it, and a parsed
/// selector is then walked by extension, superselector and unification code
/// heavier than its parser: about 1 KiB a level was measured for the parse
/// alone. Real stylesheets nest a handful of levels, so a generous figure
/// costs nothing.
pub(crate) const SELECTOR_LEVEL_COST: usize = if cfg!(debug_assertions) { 64 << 10 } else { 8 << 10 };

/// The state of the compile running on this thread, kept in one `Cell` so a
/// check costs one thread-local read: checks sit on every expression and
/// statement the evaluator runs.
#[derive(Clone, Copy, Default, PartialEq, Eq, Debug)]
struct Guard {
    /// The stack position where the compile started; 0 when none is running.
    base: usize,
    /// How many bytes the compile may use.
    limit: usize,
    /// Bytes charged by [`Chain`]s still being built.
    charged: usize,
    /// The charged depth of the deepest tree a [`Chain`] finished since the
    /// innermost open chain started or last folded: the operands it is about
    /// to fold, which a finished chain no longer charges for itself.
    finished: usize,
    /// Code that cannot return an error reached the limit ([`trip`]): every
    /// later check fails, and the compile ends in `Stack Overflow`.
    tripped: bool,
}

thread_local! {
    static GUARD: Cell<Guard> = const {
        Cell::new(Guard { base: 0, limit: 0, charged: 0, finished: 0, tripped: false })
    };
}

/// The address of a local in this frame: the current stack position.
#[inline(always)]
fn position() -> usize {
    let probe = 0u8;
    // `black_box` keeps the local in memory, so its address is a real stack
    // slot rather than one the optimizer is free to invent.
    std::hint::black_box(&probe) as *const u8 as usize
}

fn update(f: impl FnOnce(&mut Guard)) {
    GUARD.with(|g| {
        let mut v = g.get();
        f(&mut v);
        g.set(v);
    });
}

/// Restores the previous guard when the compile that entered it ends.
pub(crate) struct Scope {
    /// The enclosing compile's guard, or the idle one for the outermost.
    outer: Guard,
}

/// Start guarding a compile that may use `limit` bytes of stack from here.
///
/// A compile nested inside another on the same thread (a custom function or a
/// warn handler that compiles) keeps the outer compile's base and limit: both
/// run on the same stack, and what matters is how much of it is used in all.
/// Whether the nested one tripped is its own business, though: its result
/// already says so, and a host that handles that error has not made the outer
/// compile overflow. So the outer state comes back when the nested scope ends.
pub(crate) fn enter(limit: usize) -> Scope {
    let outer = GUARD.with(Cell::get);
    if outer.base == 0 {
        let base = position();
        GUARD.with(|g| {
            g.set(Guard {
                base,
                limit,
                ..Guard::default()
            })
        });
    }
    Scope { outer }
}

impl Drop for Scope {
    fn drop(&mut self) {
        let outer = self.outer;
        GUARD.with(|g| g.set(outer));
    }
}

/// Whether the running compile reached its limit in code that could not
/// report it. The compile entry points turn a result into `Stack Overflow`
/// when this is set, so a selector function that gave up is never mistaken
/// for one that answered.
pub(crate) fn tripped() -> bool {
    GUARD.with(Cell::get).tripped
}

/// A compile's result, or `Stack Overflow` if the guard fired anywhere along
/// the way. Once it has fired, nothing that followed is to be trusted: a
/// selector function that gave up answered `None`, and a speculative parse
/// (try one reading, backtrack on error) can swallow the overflow and fail
/// later with an unrelated message (`expected ":"`). The positioned overflow
/// is kept when it is the error that reached the top.
pub(crate) fn untrip<T>(result: Result<T, Error>) -> Result<T, Error> {
    if !tripped() {
        return result;
    }
    match result {
        Err(e) if e.message == MESSAGE => Err(e),
        _ => Err(Error::unpositioned(MESSAGE)),
    }
}

/// For code that cannot return an error (an `Option` or `bool` answer): true,
/// and the guard tripped, once the compile is over its limit. The caller
/// gives up (`None`), and the next check anywhere fails with `Stack Overflow`.
pub(crate) fn trip() -> bool {
    if exhausted(0, 0) {
        update(|g| g.tripped = true);
        true
    } else {
        false
    }
}

/// How far past its limit a compile may go before the unpositioned
/// [`check`] fires. A call site that can point at the construct
/// ([`check_at`]) should be the one that reports the overflow, and on most
/// paths it is less than a level away, so the fallback waits this much
/// longer. It must stay well inside the margin every limit leaves below the
/// real stack.
const FALLBACK_SLACK: usize = 64 << 10;

/// Whether the running compile has used more than `limit + slack` bytes: the
/// real stack below its base, plus what the chains being built have charged,
/// plus `extra` the caller is about to need.
#[inline]
fn exhausted(extra: usize, slack: usize) -> bool {
    let g = GUARD.with(Cell::get);
    g.base != 0
        && (g.tripped
            || g.base
                .saturating_sub(position())
                .saturating_add(g.charged)
                .saturating_add(extra)
                > g.limit.saturating_add(slack))
}

/// The charge for one left-deep chain while it is built: see [`LEVEL_COST`].
/// Create one per parse function whose loop folds a node into a new parent,
/// call [`Chain::level`] before each fold, and let it drop when the function
/// returns. A chain nested inside another (an operand that is itself a chain)
/// adds to the outer one's charge, as it would add to the stack if parsing
/// recursed.
///
/// A chain that has returned still counts: its tree is now an operand of
/// whatever folds it next. `((a + a) + a) + a …`, each group parenthesized,
/// or `1 * 1 * … + 1 * 1 * …` across precedence levels, makes a tree as deep
/// as all its chains together while charging only one at a time. So a chain
/// that ends leaves its depth (its own levels plus its deepest operand's)
/// behind as `finished`, and each fold checks the tree it makes, a level on
/// top of the deepest of its operands. While the chain stays open it charges
/// only its own levels, though: the operand it already folded is a sibling of
/// the one it parses next, not its parent, so `(g) + (g) + (g)` is no deeper
/// than `(g) + (g)` and a wide expression is not charged for its width.
pub(crate) struct Chain {
    /// The depth of the tree folded so far, in bytes, its operands included.
    depth: usize,
    /// What this chain has added to the compile's charge: its own levels.
    charged: usize,
    /// The enclosing chain's `finished`, put back when this one ends.
    outer_finished: usize,
}

impl Chain {
    pub(crate) fn new() -> Self {
        let mut outer_finished = 0;
        update(|g| outer_finished = std::mem::take(&mut g.finished));
        Self {
            depth: 0,
            charged: 0,
            outer_finished,
        }
    }

    /// Charge one more level, and fail with `Stack Overflow` at `pos` once
    /// the compile is over its limit counting the whole tree this fold makes:
    /// the level on top of the deepest operand.
    pub(crate) fn level(&mut self, pos: crate::scanner::Pos) -> Result<(), Error> {
        let mut operands = 0;
        update(|g| operands = std::mem::take(&mut g.finished));
        self.depth = self.depth.max(operands) + LEVEL_COST;
        self.charge(LEVEL_COST);
        if exhausted(self.depth.saturating_sub(self.charged), 0) {
            update(|g| g.tripped = true);
            Err(Error::at(MESSAGE, pos))
        } else {
            Ok(())
        }
    }

    /// Charge `cost` for code that cannot return an error: false, with the
    /// guard tripped (see [`trip`]), once the compile is over its limit.
    pub(crate) fn level_or_trip(&mut self, cost: usize) -> bool {
        self.charge(cost);
        !trip()
    }

    fn charge(&mut self, cost: usize) {
        self.charged += cost;
        update(|g| g.charged += cost);
    }
}

impl Drop for Chain {
    fn drop(&mut self) {
        let (charged, depth, outer) = (self.charged, self.depth, self.outer_finished);
        if charged != 0 || outer != 0 {
            update(|g| {
                g.charged = g.charged.saturating_sub(charged);
                g.finished = outer.max(depth.max(g.finished));
            });
        }
    }
}

/// Fail with dart-sass's `Stack Overflow`, pointing at `pos` (spanning
/// `length` bytes), once the running compile has used more stack than its
/// limit. Call it where a stylesheet makes sasso recurse and the construct
/// responsible is known: a call, an `@include`, a nested block.
#[inline]
pub(crate) fn check_at(pos: crate::scanner::Pos, length: usize) -> Result<(), Error> {
    if trip() {
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
    if exhausted(0, FALLBACK_SLACK) {
        update(|g| g.tripped = true);
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
        let base = GUARD.with(Cell::get).base;
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
            // Once fired, the guard stays tripped for the rest of the compile:
            // anything after the overflow could have been swallowed into a
            // wrong answer, so even shallow recursion fails now.
            assert!(tripped());
            assert!(recurse(10).is_err());
            assert!(
                untrip::<()>(Ok(())).is_err(),
                "an Ok after the overflow is not trusted"
            );
        }
        // The scope is gone, so the guard is off and untripped again.
        assert!(!tripped());
        assert!(recurse(50).is_ok());
        assert_eq!(GUARD.with(Cell::get), Guard::default());
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
