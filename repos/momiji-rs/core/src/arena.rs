//! The scoped bump allocator (perf #5) — the library's one `unsafe` module.
//!
//! A single `compile()` is a flood of short-lived allocations freed all at once,
//! so within a compile scope every allocation is a pointer bump from a
//! per-thread arena, and the whole arena is reset when the scope ends. Outside a
//! scope, allocations forward to the system allocator. Because a compile is
//! `!Send` (the evaluator uses `Rc`), each thread keeps its own arena, so the
//! state is thread-local and single-threaded (`Cell`, not atomics).
//!
//! ## Safety strategy
//!
//! - Bump arithmetic is the pure [`bump_compute`] (exhaustively unit-tested:
//!   alignment / boundary / overflow, no `unsafe`).
//! - Pointers are derived via `base.add(..)` (never `addr as *mut u8`) so they
//!   keep provenance — required for Miri's Stacked/Tree-Borrows checks.
//! - The thread-local [`ThreadState`] gives its region and registry slot back
//!   when the thread ends. It used to be POD so that the first TLS access
//!   registered no destructor — but leaving the 2 GiB reservation behind cost
//!   an embedder with short-lived threads one per compile, until the host
//!   could no longer `fork()`. The destructor frees rather than allocates, and
//!   `alloc`/`realloc` reach the state through `try_with` so allocations made
//!   while other thread-locals are being dropped route to System instead of
//!   panicking on a destroyed slot.
//! - [`Arena`] (test-only) is a standalone, `Drop`-ing twin of the same bump +
//!   provenance logic, run under `cargo miri test` for UB detection without
//!   leaking (Miri does not execute `#[global_allocator]`, so the live
//!   [`ScopedAlloc`] path is covered by AddressSanitizer + the full sass-spec
//!   suite run under the arena instead).

#![allow(unsafe_code)]
// Some scope primitives are wired up in later steps (Importer boundary).
#![allow(dead_code)]

use std::alloc::{GlobalAlloc, Layout, System};
use std::cell::Cell;
use std::sync::atomic::{AtomicBool, AtomicPtr, AtomicUsize, Ordering};

// =========================================================================
// Process-global arena-region registry.
//
// `dealloc` only needs to answer "is this pointer inside SOME thread's arena
// region?" — an in-arena free is a no-op (reclaimed wholesale on scope reset),
// anything else forwards to System. A global table of `[base, end)` ranges
// answers that with two atomic loads per registered region and no thread-local
// access. This halves the macOS `_tlv_get_addr` dynamic-TLS traffic, which
// `alloc` (which genuinely needs the per-thread cursor) still pays.
//
// What a slot holds and what it lends are different things. `base`/`end` are
// WRITE-ONCE: a slot's region is created the first time anyone uses that slot
// and lives for the rest of the process. What a thread takes and gives back is
// the RIGHT to bump inside it — `taken`, claimed by CAS at the start of a
// compile and released when the outermost scope ends, not when the thread
// does. `REGION_SLOTS` bounds the scan and never shrinks.
//
// Write-once is the whole safety argument, and it is why the region is pooled
// rather than freed. Freeing it would let a slot point at one range and then
// another, and `in_any_arena` reads `base` and `end` separately: a reader can
// take `base` from the old region, lose the slot to a new owner, and take
// `end` from the new one. That pair describes a range neither region ever had,
// and a System pointer inside it would be called arena-owned — where freeing
// is a no-op, so it would leak. Pooling removes the question instead of
// synchronising around it; no epoch or reader guard is needed because nothing
// a reader can observe ever changes.
//
// Memory ordering: `base` is published with Release and read with ACQUIRE,
// which is what makes the preceding `end` store visible. Relaxed on both would
// let a weakly ordered target (aarch64, which this ships on) hand back a
// freshly published `base` with the `end` that preceded it — zero — and call a
// live arena pointer a System one. Everything after the acquire is relaxed:
// a nonzero `base` from a write-once slot is its final value, so containment
// is real. A false "not in arena" (a stale 0) could only misroute a pointer in
// the unobserved region, and a thread always sees its own publication, while
// any pointer legitimately handed to another thread rides that channel's
// happens-before edge. A thread with no such edge cannot hold the pointer.
// (The old per-thread check misclassified cross-thread frees of arena
// pointers as System allocations — the registry handles them correctly.)
// =========================================================================

/// Max arena regions, and so the most compiles that can bump at once.
///
/// Regions are pooled and leased for the length of one compile, so this caps
/// CONCURRENT compiles — not threads, and not history. A thread that finishes
/// compiling gives its lease back while staying alive, so a worker pool larger
/// than this is fine as long as they are not all inside `compile()` together.
/// A thread arriving when every region is leased runs without an arena and
/// tries again on its next compile.
const MAX_ARENAS: usize = 128;

/// A `[base, end)` region plus whether a thread currently holds it.
///
/// `base` and `end` are written ONCE, the first time a slot is used, and never
/// again — the region outlives every thread that borrows it. That is what lets
/// `in_any_arena` read the pair without synchronising against reuse: there is
/// no reuse of the *range* to synchronise against, only of the right to bump
/// within it. A design that freed the region and re-pointed the slot would
/// have to make the two loads atomic with respect to each other, since a
/// reader can load `base`, lose the slot to a new owner, and then load that
/// owner's `end` — pairing a stale base with a fresh end and classifying an
/// unrelated System pointer as arena-owned, where freeing is a no-op and the
/// allocation would leak.
struct Region {
    /// The region's start, kept as a pointer rather than an address so that a
    /// thread leasing a slot another thread created gets the pointer
    /// `System.alloc` returned, provenance and all. Storing it as a `usize`
    /// and casting back would be the `addr as *mut u8` this module's safety
    /// strategy rules out: every allocation handed out is derived from this
    /// with `add`, so a base without provenance makes each of them undefined
    /// under strict provenance, and Miri's Stacked/Tree-Borrows would say so.
    base: AtomicPtr<u8>,
    end: AtomicUsize,
    /// Held by a live thread. Readers ignore this: a region is a region
    /// whether or not anyone is bumping in it right now.
    taken: AtomicBool,
}

#[allow(clippy::declare_interior_mutable_const)] // repeated-element array init (MSRV < 1.79)
const ZERO_REGION: Region = Region {
    base: AtomicPtr::new(std::ptr::null_mut()),
    end: AtomicUsize::new(0),
    taken: AtomicBool::new(false),
};
/// High-water mark: slots `0..REGION_SLOTS` have been used at some point and
/// are what [`in_any_arena`] scans. It never shrinks — a slot given back is
/// skipped by its zero `base`, not by moving this — so the scan bound stays
/// monotonic while the slots beneath it are recycled.
static REGION_SLOTS: AtomicUsize = AtomicUsize::new(0);
static REGIONS: [Region; MAX_ARENAS] = [ZERO_REGION; MAX_ARENAS];

/// Borrow a free slot. `None` when every slot is held right now — which is a
/// moment, not a verdict: the holders are compiling and will give theirs back.
fn claim_slot(preferred: usize) -> Option<usize> {
    // The slot this thread held for its previous compile, if it is still free:
    // the region is then already warm in cache and TLB. Leases are given back
    // between compiles, so without this a busy thread would wander the array.
    if preferred != NO_SLOT
        && REGIONS[preferred]
            .taken
            .compare_exchange(false, true, Ordering::AcqRel, Ordering::Relaxed)
            .is_ok()
    {
        return Some(preferred);
    }
    for (idx, region) in REGIONS.iter().enumerate() {
        if region
            .taken
            .compare_exchange(false, true, Ordering::AcqRel, Ordering::Relaxed)
            .is_ok()
        {
            // Scan bound for `in_any_arena`. Raised on claim rather than on
            // publication; a slot whose region does not exist yet reads
            // `base == 0` and is skipped.
            REGION_SLOTS.fetch_max(idx + 1, Ordering::AcqRel);
            return Some(idx);
        }
    }
    None
}

/// Give the slot back. The REGION stays registered — see [`Region`]. Nothing
/// else may be written here: the moment `taken` reads false another thread can
/// take the slot, and this one has no business touching it afterwards.
fn release_slot(idx: usize) {
    REGIONS[idx].taken.store(false, Ordering::Release);
}

/// Whether `p` lies inside any registered arena region.
///
/// This reads `base` and `end` and ignores `taken` entirely: the question is
/// whether the ADDRESS belongs to an arena, not whether anyone is bumping in
/// it at this instant. A region that no thread currently leases still holds
/// pointers handed out moments ago, and they must keep routing here.
///
/// There is exactly one transition to synchronise with — the first time a
/// slot is ever used, when its region is created. `end` is written, then
/// `base` with `Release`, and `base` gates every reader; a slot whose region
/// does not exist yet reads `base == 0` and is skipped. After that neither
/// value ever changes again, which is what makes the two separate loads safe.
/// Leasing writes only `taken`, which nothing here reads.
///
/// The ACQUIRE is what makes that one transition hold. `base` is published
/// with `Release`, and release pairs with acquire or with nothing at all: read
/// relaxed there is no happens-before edge, and a weakly ordered target —
/// aarch64, which this ships on — may hand back a freshly published `base`
/// alongside the `end` that preceded it, which is zero. A live arena pointer
/// then compares outside its own region, `dealloc` calls it a System pointer,
/// and frees something System never allocated. The scan is short — the
/// high-water mark is how many slots have ever been leased, not `MAX_ARENAS`
/// — so the acquire costs little and buys the guarantee this comment makes.
#[inline]
fn in_any_arena(p: usize) -> bool {
    let n = REGION_SLOTS.load(Ordering::Relaxed).min(MAX_ARENAS);
    for r in &REGIONS[..n] {
        // Pointer to address for the comparison only. That direction is free:
        // it is deriving a pointer FROM an address that loses provenance, and
        // nothing here is dereferenced.
        let base = r.base.load(Ordering::Acquire) as usize;
        if base != 0 && p >= base && p < r.end.load(Ordering::Relaxed) {
            return true;
        }
    }
    false
}

/// Pure bump arithmetic over absolute addresses: align `cur` up to `align`, add
/// `size`, and check the result fits at or below `end` (exclusive). Returns
/// `(aligned_start, new_cursor)` or `None` on overflow / no fit. Touches no
/// memory. `align` must be a power of two (guaranteed by [`Layout`]).
fn bump_compute(cur: usize, align: usize, size: usize, end: usize) -> Option<(usize, usize)> {
    let aligned = cur.checked_add(align - 1)? & !(align - 1);
    let next = aligned.checked_add(size)?;
    (next <= end).then_some((aligned, next))
}

// ── Arena reservation size ──────────────────────────────────────────────
//
// The region is reserved up front on first use. On a 64-bit host this is
// virtual — physical pages commit lazily on first touch, so a huge unused
// reservation costs ~nothing, and the size is a fixed 2 GiB. On wasm32 there
// is no lazy commit (`memory.grow` zero-fills and commits every page
// immediately) and the address space is only 4 GiB, so the reservation must
// be a realistic peak working-set bound: a single large-stylesheet compile
// peaks around 25 MiB, and the region grows the wasm heap ONCE on the first
// compile and is then reused (reset, not freed) — a fixed footprint, not
// per-compile growth. Anything that overflows the region spills to the system
// allocator with no loss of correctness.
//
// The wasm size has two layers of developer control:
//   • compile-time default — `SASSO_WASM_ARENA_MB` at build time (default 32),
//   • runtime override — [`set_arena_bytes`] before the first compile (0
//     disables the arena entirely: every allocation forwards to System).
// Native ignores both and always uses its 2 GiB virtual reservation.

/// Const decimal parser for the `SASSO_WASM_ARENA_MB` build-time value.
#[cfg(target_arch = "wasm32")]
const fn parse_mb(s: &str) -> usize {
    let bytes = s.as_bytes();
    let mut n = 0usize;
    let mut i = 0;
    while i < bytes.len() {
        let b = bytes[i];
        assert!(
            b >= b'0' && b <= b'9',
            "SASSO_WASM_ARENA_MB must be decimal digits"
        );
        n = n * 10 + (b - b'0') as usize;
        i += 1;
    }
    n
}

/// Compile-time default arena size (wasm): `SASSO_WASM_ARENA_MB` MiB, else 32.
#[cfg(target_arch = "wasm32")]
const WASM_DEFAULT_ARENA_SIZE: usize = match option_env!("SASSO_WASM_ARENA_MB") {
    Some(s) => parse_mb(s) * 1024 * 1024,
    None => 32 * 1024 * 1024,
};

/// Runtime override of the wasm arena size: `0` = unset (use the compile-time
/// default), `usize::MAX` = explicitly disabled, anything else = that many
/// bytes. Read only on wasm; native's [`effective_arena_size`] ignores it.
static ARENA_CONFIG: AtomicUsize = AtomicUsize::new(0);

/// Override the wasm arena reservation size, in **bytes**. Must be called
/// BEFORE the first `compile()` — the region is reserved on first use and then
/// fixed, so a later call has no effect. `0` disables the arena entirely
/// (every allocation forwards to the system allocator: lower memory, slower).
/// No effect on native targets (they always use the 2 GiB virtual reservation).
pub fn set_arena_bytes(bytes: usize) {
    ARENA_CONFIG.store(if bytes == 0 { usize::MAX } else { bytes }, Ordering::Relaxed);
}

/// The arena size to reserve, resolving the runtime override against the
/// compile-time default. `0` means "disabled" (the caller forwards to System).
#[cfg(target_arch = "wasm32")]
#[inline]
fn effective_arena_size() -> usize {
    match ARENA_CONFIG.load(Ordering::Relaxed) {
        0 => WASM_DEFAULT_ARENA_SIZE,
        usize::MAX => 0,
        n => n,
    }
}

#[cfg(not(target_arch = "wasm32"))]
#[inline]
fn effective_arena_size() -> usize {
    2 * 1024 * 1024 * 1024 // 2 GiB virtual; the runtime override is wasm-only
}

/// Per-thread bump state. Its `Drop` returns the region and the registry slot
/// when the thread ends — see the module-level safety note for why the
/// allocator reaches this through `try_with`.
struct ThreadState {
    base: Cell<*mut u8>,
    end: Cell<usize>,
    cursor: Cell<usize>,
    /// Scope nesting depth. `0` = inactive: allocations pass through to System.
    depth: Cell<u32>,
    /// [`pause`] nesting count. While `> 0`, allocations pass through to
    /// System even inside a scope, without touching `depth` — so a compile
    /// started from within a paused callback nests as usual and cannot mistake
    /// itself for the outermost scope and reset the arena under its caller.
    paused: Cell<u32>,
    /// Set once if [`Self::reserve`] fails for a reason that cannot change —
    /// the arena is disabled, or the 2 GiB reservation itself failed. The
    /// alloc path then forwards straight to System without retrying the
    /// `#[cold]` reservation on every allocation.
    reserve_failed: Cell<bool>,
    /// Set when every registry slot was busy. Separate from `reserve_failed`
    /// because, now that slots come back, "full" is a moment rather than a
    /// verdict: a thread that started while 128 others held slots would
    /// otherwise run on the system allocator for the rest of its life. Cleared
    /// when a scope opens, so each compile gets one fresh attempt — and not
    /// per allocation, which would mean a 2 GiB reserve-and-free apiece.
    registry_full: Cell<bool>,
    /// Registry slot this thread is currently leasing. `NO_SLOT` between
    /// compiles — the lease is given back when the outermost scope ends, so
    /// the cap is on threads compiling AT ONCE rather than on threads that
    /// have ever compiled. Holding it for the life of the thread would leave
    /// a pool of 128 long-lived workers permanently full, and everyone who
    /// arrived later on the system allocator, silently and for good.
    slot: Cell<usize>,
    /// The slot leased for the previous compile, tried first next time so a
    /// busy thread keeps the same warm region.
    last_slot: Cell<usize>,
}

/// No registry slot held.
const NO_SLOT: usize = usize::MAX;

/// Why a reservation did or did not happen — the two failures differ in how
/// long they last.
enum Reserved {
    Yes,
    /// Disabled or out of memory: nothing about a later attempt would differ.
    Never,
    /// Every registry slot was taken. Slots come back, so this one can.
    NotNow,
}

impl ThreadState {
    const fn new() -> ThreadState {
        ThreadState {
            base: Cell::new(std::ptr::null_mut()),
            end: Cell::new(0),
            cursor: Cell::new(0),
            depth: Cell::new(0),
            paused: Cell::new(0),
            reserve_failed: Cell::new(false),
            registry_full: Cell::new(false),
            slot: Cell::new(NO_SLOT),
            last_slot: Cell::new(NO_SLOT),
        }
    }

    /// Take a pooled region for this thread, creating it if this slot has
    /// never been used. The caller forwards the request to the system
    /// allocator on anything but [`Reserved::Yes`] — and the two failures
    /// differ: [`Reserved::Never`] is disabled or out of memory and is
    /// remembered, [`Reserved::NotNow`] is every slot busy and is retried when
    /// the next scope opens.
    #[cold]
    fn reserve(&self) -> Reserved {
        let size = effective_arena_size();
        if size == 0 {
            return Reserved::Never; // disabled: run on the system allocator
        }
        let Some(slot) = claim_slot(self.last_slot.get()) else {
            return Reserved::NotNow; // every slot held; a holder will finish
        };
        let region = &REGIONS[slot];
        let mut base = region.base.load(Ordering::Acquire);
        if base.is_null() {
            // First thread ever to hold this slot: give it a region, once.
            // Every later holder bumps in the same one.
            let Ok(layout) = Layout::from_size_align(size, 4096) else {
                release_slot(slot);
                return Reserved::Never;
            };
            // SAFETY: non-zero size, 4096 is a valid power-of-two alignment.
            let p = unsafe { System.alloc(layout) };
            if p.is_null() {
                release_slot(slot);
                return Reserved::Never;
            }
            // `end` before `base`: `base` is what readers gate on, so writing
            // it last means a reader sees the whole region or skips the slot.
            region.end.store(p as usize + size, Ordering::Relaxed);
            region.base.store(p, Ordering::Release);
            base = p;
        }
        self.slot.set(slot);
        self.base.set(base);
        self.end.set(region.end.load(Ordering::Relaxed));
        self.cursor.set(base as usize);
        Reserved::Yes
    }
}

impl Drop for ThreadState {
    /// Give back a lease the thread still holds.
    ///
    /// Normally there is none: [`reset`] hands it back when the compile ends.
    /// This catches the paths that do not get there — a thread unwinding out
    /// of a compile, or one that reserved and then died.
    ///
    /// The region itself stays. It is pooled, and the next thread to lease
    /// this slot bumps in the same memory. What must not happen is what
    /// happened before any of this: a reservation per thread that ever
    /// compiled, 2 GiB of address space each, until an embedder with
    /// short-lived threads (the napi addon spawns one per async compile)
    /// leaves the host unable to `fork()`.
    ///
    /// This runs during TLS teardown, which is why `alloc` reaches the state
    /// through `try_with`: allocations happen while other thread-locals are
    /// being dropped, and after this one is gone they must route to System
    /// rather than panic on a destroyed TLS slot.
    fn drop(&mut self) {
        let slot = self.slot.get();
        if slot == NO_SLOT {
            return;
        }
        self.slot.set(NO_SLOT);
        self.base.set(std::ptr::null_mut());
        self.end.set(0);
        self.cursor.set(0);
        release_slot(slot);
    }
}

thread_local! {
    // `const {}` init: no lazy allocation, so reaching this from inside the
    // global allocator cannot re-enter it. The destructor (above) means the
    // state CAN be gone late in thread teardown, so the allocator uses
    // `try_with` and falls back to System when it is.
    static TL: ThreadState = const { ThreadState::new() };
}

/// A scoped bump global allocator. Inside a `compile()` scope it bump-allocates
/// from a per-thread arena that is reset when the scope ends; outside any scope
/// it forwards to the system allocator. Install it in a binary or wasm wrapper:
///
/// ```ignore
/// #[global_allocator]
/// static ALLOC: sasso::ScopedAlloc = sasso::ScopedAlloc;
/// ```
///
/// It is safe to install even if `compile` is never called: with no active scope
/// every request goes straight to the system allocator.
pub struct ScopedAlloc;

unsafe impl GlobalAlloc for ScopedAlloc {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        // `try_with`, not `with`: freeing other thread-locals during teardown
        // allocates, and by then this one may already be dropped. `with` would
        // panic there — inside the global allocator, which aborts the process.
        // No state means no scope, which means System, which is correct.
        let Ok(p) = TL.try_with(|tl| {
            if tl.depth.get() == 0 || tl.paused.get() > 0 {
                // SAFETY: forwarding an unchanged layout to the system allocator.
                return unsafe { System.alloc(layout) };
            }
            if tl.base.get().is_null() {
                // Take a region once. A permanent failure (disabled, out of
                // memory) is remembered for the life of the thread; a busy
                // registry is remembered only until the next scope opens, so
                // this does not re-run the cold path per allocation either
                // way.
                if tl.reserve_failed.get() || tl.registry_full.get() {
                    return unsafe { System.alloc(layout) };
                }
                match tl.reserve() {
                    Reserved::Yes => {}
                    Reserved::Never => {
                        tl.reserve_failed.set(true);
                        return unsafe { System.alloc(layout) };
                    }
                    Reserved::NotNow => {
                        tl.registry_full.set(true);
                        return unsafe { System.alloc(layout) };
                    }
                }
            }
            match bump_compute(tl.cursor.get(), layout.align(), layout.size(), tl.end.get()) {
                Some((aligned, next)) => {
                    tl.cursor.set(next);
                    let base = tl.base.get();
                    // SAFETY: bump_compute guarantees base <= aligned and
                    // aligned + size <= base + size, so the offset is in-bounds.
                    unsafe { base.add(aligned - base as usize) }
                }
                // Arena exhausted → fall back to the system allocator.
                // SAFETY: forwarding an unchanged layout to the system allocator.
                None => unsafe { System.alloc(layout) },
            }
        }) else {
            // SAFETY: forwarding an unchanged layout to the system allocator.
            return unsafe { System.alloc(layout) };
        };
        p
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        // The global region registry answers "arena or System?" without a
        // thread-local lookup (see its module section above).
        if !in_any_arena(ptr as usize) {
            // SAFETY: not from any arena, so it came from the system
            // allocator with this same layout.
            unsafe { System.dealloc(ptr, layout) };
        }
        // in-arena: no-op (reclaimed wholesale on scope reset)
    }

    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        // Bump-arena fast path: if `ptr` is the MOST RECENT allocation in this
        // thread's arena (its end sits exactly at the cursor), resize it in
        // place by moving the cursor — no copy, and no dead intermediate buffer
        // left behind. A naive realloc (alloc-new + copy + no-op dealloc) is
        // what makes a growing `Vec` leak arena space on every doubling
        // (4→8→16→…); this reclaims it for the common "grow the value just
        // allocated" pattern, the dominant case in the parser/evaluator.
        // `try_with` for the same reason as `alloc`: no state means no scope,
        // so nothing can be resized in place and the copy path is correct.
        let resized = TL.try_with(|tl| {
            if tl.depth.get() == 0 || tl.paused.get() > 0 {
                return false;
            }
            let base = tl.base.get();
            if base.is_null() {
                return false;
            }
            let addr = ptr as usize;
            // `ptr` must lie in THIS arena (≥ base) AND be the last bump
            // (`addr + old_size == cursor`). A system pointer or an earlier
            // (non-tail) arena block fails this and takes the copy fallback.
            if addr < base as usize || addr + layout.size() != tl.cursor.get() {
                return false;
            }
            match addr.checked_add(new_size) {
                Some(new_end) if new_end <= tl.end.get() => {
                    tl.cursor.set(new_end);
                    true
                }
                // A grow past the arena end (or overflow) → copy fallback.
                _ => false,
            }
        });
        if resized.unwrap_or(false) {
            return ptr;
        }
        // Fallback: the stock `GlobalAlloc::realloc` (alloc new, copy the
        // overlap, free old). `self.alloc`/`self.dealloc` route arena-vs-system
        // themselves; the old block, if in-arena, is reclaimed at scope reset.
        // SAFETY: same contract and aliasing as the default impl.
        unsafe {
            let new_layout = Layout::from_size_align_unchecked(new_size, layout.align());
            let new_ptr = self.alloc(new_layout);
            if !new_ptr.is_null() {
                core::ptr::copy_nonoverlapping(ptr, new_ptr, layout.size().min(new_size));
                self.dealloc(ptr, layout);
            }
            new_ptr
        }
    }
}

/// An RAII scope marker. Construct it on entering a compile; on `drop` (the
/// panic / early-exit path) it leaves the scope and resets the arena. The
/// success path in `compile` finishes manually — leaving, copying the result
/// out, then resetting — and `mem::forget`s the guard.
pub(crate) struct Scope;

impl Scope {
    pub(crate) fn enter() -> Scope {
        TL.with(|tl| {
            tl.depth.set(tl.depth.get() + 1);
            // One fresh attempt per compile if the registry was full last time.
            // Not per allocation: that would reserve and free 2 GiB apiece.
            tl.registry_full.set(false);
        });
        Scope
    }
}

impl Drop for Scope {
    fn drop(&mut self) {
        // Panic / early-exit path: leave and, if outermost, reset.
        if leave_no_reset() {
            reset();
        }
    }
}

/// Leave the current scope WITHOUT resetting, returning whether this was the
/// outermost scope. The success path copies the result out before [`reset`].
pub(crate) fn leave_no_reset() -> bool {
    TL.with(|tl| {
        let d = tl.depth.get().saturating_sub(1);
        tl.depth.set(d);
        d == 0
    })
}

/// Reset the arena to empty. Only resets when no scope is active (so a nested
/// scope can't free an outer scope's allocations).
pub(crate) fn reset() {
    TL.with(|tl| {
        if tl.depth.get() != 0 {
            return;
        }
        // The compile is over and `compile()` has already copied its result
        // out to the system allocator, so nothing points in here any more:
        // hand the lease back for the next thread that needs one.
        let slot = tl.slot.get();
        if slot == NO_SLOT {
            tl.cursor.set(tl.base.get() as usize);
            return;
        }
        tl.last_slot.set(slot);
        tl.slot.set(NO_SLOT);
        tl.base.set(std::ptr::null_mut());
        tl.end.set(0);
        tl.cursor.set(0);
        release_slot(slot);
    });
}

/// Suspend arena allocation (requests go to System) around a caller callback
/// whose allocations may outlive the arena — an `Importer`, a `WarnHandler`.
/// The scope depth is left untouched: if the callback itself runs a `compile`,
/// that nested scope sees a live outer scope, so on return it neither resets
/// the arena nor frees its caller's state. Returns a guard; the pause lifts
/// when it drops — on unwind too, so a panicking callback cannot leave the
/// thread routing every later allocation to System.
pub(crate) fn pause() -> Paused {
    TL.with(|tl| tl.paused.set(tl.paused.get() + 1));
    Paused
}

/// RAII token from [`pause`]: dropping it lifts one pause.
#[must_use]
pub(crate) struct Paused;

impl Drop for Paused {
    fn drop(&mut self) {
        TL.with(|tl| tl.paused.set(tl.paused.get().saturating_sub(1)));
    }
}

// =========================================================================
// Test-only standalone arena: a `Drop`-ing twin of the bump + provenance logic
// above, used to exercise it under `cargo miri test` without leaking.
// =========================================================================

#[cfg(test)]
struct Arena {
    base: *mut u8,
    size: usize,
    end: usize,
    cursor: Cell<usize>,
}

#[cfg(test)]
impl Arena {
    fn with_system_backing(size: usize) -> Option<Arena> {
        let layout = Layout::from_size_align(size, 4096).ok()?;
        // SAFETY: non-zero size, valid align.
        let base = unsafe { System.alloc(layout) };
        if base.is_null() {
            return None;
        }
        Some(Arena {
            base,
            size,
            end: base as usize + size,
            cursor: Cell::new(base as usize),
        })
    }

    fn alloc(&self, layout: Layout) -> Option<*mut u8> {
        let (aligned, next) = bump_compute(self.cursor.get(), layout.align(), layout.size(), self.end)?;
        self.cursor.set(next);
        // SAFETY: in-bounds offset (see bump_compute).
        Some(unsafe { self.base.add(aligned - self.base as usize) })
    }

    fn reset(&self) {
        self.cursor.set(self.base as usize);
    }

    fn used(&self) -> usize {
        self.cursor.get() - self.base as usize
    }

    fn contains(&self, ptr: *mut u8) -> bool {
        let p = ptr as usize;
        p >= self.base as usize && p < self.end
    }

    /// Twin of [`ScopedAlloc::realloc`]'s logic: extend the last bump in place,
    /// else copy to a fresh allocation.
    fn realloc(&self, ptr: *mut u8, old: Layout, new_size: usize) -> Option<*mut u8> {
        let addr = ptr as usize;
        if addr >= self.base as usize && addr + old.size() == self.cursor.get() {
            let new_end = addr.checked_add(new_size)?;
            if new_end <= self.end {
                self.cursor.set(new_end);
                return Some(ptr);
            }
        }
        let np = self.alloc(Layout::from_size_align(new_size, old.align()).ok()?)?;
        // SAFETY: np is a fresh, non-overlapping allocation of >= copy length.
        unsafe { core::ptr::copy_nonoverlapping(ptr, np, old.size().min(new_size)) };
        Some(np)
    }
}

#[cfg(test)]
impl Drop for Arena {
    fn drop(&mut self) {
        if let Ok(layout) = Layout::from_size_align(self.size, 4096) {
            // SAFETY: base came from System.alloc with this layout.
            unsafe { System.dealloc(self.base, layout) };
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// `live_regions()` is process-wide, so the tests that watch it have to
    /// not run while another one is reserving. Only arena tests ever take a
    /// region, so serialising them against each other is enough.
    static REGION_COUNT: std::sync::Mutex<()> = std::sync::Mutex::new(());

    // ---- pure bump_compute (also covered by Miri) ----

    #[test]
    fn compute_aligns_up() {
        assert_eq!(bump_compute(10, 8, 4, 1000), Some((16, 20)));
        assert_eq!(bump_compute(16, 8, 8, 1000), Some((16, 24)));
        assert_eq!(bump_compute(7, 1, 3, 1000), Some((7, 10)));
    }

    #[test]
    fn compute_every_power_of_two_alignment() {
        for align in [1usize, 2, 4, 8, 16, 32, 64, 128, 256, 4096] {
            let (aligned, next) = bump_compute(1, align, 64, usize::MAX).unwrap();
            assert_eq!(aligned % align, 0, "align {align}");
            assert_eq!(next, aligned + 64);
        }
    }

    #[test]
    fn compute_zero_size() {
        assert_eq!(bump_compute(8, 8, 0, 100), Some((8, 8)));
    }

    #[test]
    fn compute_boundary() {
        assert_eq!(bump_compute(0, 1, 100, 100), Some((0, 100)));
        assert_eq!(bump_compute(0, 1, 101, 100), None);
        assert_eq!(bump_compute(90, 8, 20, 100), None);
    }

    #[test]
    fn compute_overflow_is_none() {
        assert_eq!(bump_compute(usize::MAX, 8, 0, usize::MAX), None);
        assert_eq!(bump_compute(usize::MAX - 3, 1, 10, usize::MAX), None);
    }

    // ---- standalone Arena (run under Miri for UB) ----

    fn layout(size: usize, align: usize) -> Layout {
        Layout::from_size_align(size, align).unwrap()
    }

    #[test]
    fn realloc_extends_tail_in_place_else_copies() {
        let a = Arena::with_system_backing(64 * 1024).unwrap();
        let p = a.alloc(layout(8, 8)).unwrap();
        // SAFETY: p is a live 8-byte allocation.
        unsafe { std::ptr::write_bytes(p, 0xCD, 8) };
        let used = a.used();
        // Tail grow: same pointer, only the delta is bumped (no dead buffer).
        let p2 = a.realloc(p, layout(8, 8), 16).unwrap();
        assert_eq!(p, p2, "tail realloc grows in place");
        assert_eq!(a.used(), used + 8, "only the +8 delta is consumed");
        // SAFETY: p2 still points at the (now larger) live block.
        unsafe { assert_eq!(*p2, 0xCD, "data preserved in place") };
        // Intervening allocation makes p2 no longer the tail → copy fallback.
        let _q = a.alloc(layout(8, 8)).unwrap();
        let used_mid = a.used();
        let p3 = a.realloc(p2, layout(16, 8), 32).unwrap();
        assert_ne!(p2, p3, "non-tail realloc copies to a fresh block");
        assert!(a.used() > used_mid, "fallback allocates fresh");
        // SAFETY: p3 is the fresh block holding the copied bytes.
        unsafe { assert_eq!(*p3, 0xCD, "data copied to the new block") };
    }

    #[test]
    fn arena_alloc_is_aligned_writable_and_in_bounds() {
        let a = Arena::with_system_backing(64 * 1024).unwrap();
        for align in [1usize, 2, 4, 8, 16, 64, 256] {
            let p = a.alloc(layout(128, align)).unwrap();
            assert_eq!(p as usize % align, 0, "align {align}");
            assert!(a.contains(p));
            unsafe {
                std::ptr::write_bytes(p, 0xAB, 128);
                assert_eq!(*p, 0xAB);
                assert_eq!(*p.add(127), 0xAB);
            }
        }
    }

    #[test]
    fn arena_allocations_do_not_overlap() {
        let a = Arena::with_system_backing(64 * 1024).unwrap();
        let p1 = a.alloc(layout(64, 8)).unwrap() as usize;
        let p2 = a.alloc(layout(64, 8)).unwrap() as usize;
        assert!(p2 >= p1 + 64);
    }

    #[test]
    fn arena_full_returns_none() {
        let a = Arena::with_system_backing(4096).unwrap();
        assert!(a.alloc(layout(8192, 8)).is_none());
        assert!(a.alloc(layout(2048, 8)).is_some());
        assert!(a.alloc(layout(2048, 8)).is_some());
        assert!(a.alloc(layout(1, 1)).is_none());
    }

    #[test]
    fn arena_reset_reuses_region() {
        let a = Arena::with_system_backing(64 * 1024).unwrap();
        let p1 = a.alloc(layout(1000, 8)).unwrap();
        assert_eq!(a.used(), 1000);
        a.reset();
        assert_eq!(a.used(), 0);
        let p2 = a.alloc(layout(1000, 8)).unwrap();
        assert_eq!(p1, p2);
        unsafe { std::ptr::write_bytes(p2, 0xCD, 1000) };
    }

    // ---- ScopedAlloc routing (NOT under Miri: it doesn't run a
    // #[global_allocator], so these exercise the routing directly. Each takes
    // a lease for the length of its scope and gives it back at `reset`; the
    // pooled region stays registered either way, which is why the tests below
    // spawn their own threads to ask about leases rather than about memory.)
    // These call ScopedAlloc directly; the test thread's own allocations go to
    // the real (system) global allocator, so they don't perturb the arena. ----

    #[test]
    #[cfg_attr(miri, ignore)]
    fn scoped_routes_to_system_when_inactive() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        // No scope entered: depth 0 → System. dealloc must round-trip.
        let l = layout(64, 8);
        let p = unsafe { ScopedAlloc.alloc(l) };
        assert!(!p.is_null());
        assert!(!TL.with(|tl| {
            let b = tl.base.get() as usize;
            (p as usize) >= b && (p as usize) < tl.end.get() && b != 0
        }));
        unsafe { ScopedAlloc.dealloc(p, l) };
    }

    #[test]
    #[cfg_attr(miri, ignore)]
    fn scoped_bumps_inside_scope_and_resets() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let l = layout(128, 16);
        let scope = Scope::enter();
        let p1 = unsafe { ScopedAlloc.alloc(l) };
        let p2 = unsafe { ScopedAlloc.alloc(l) };
        let in_arena = |p: *mut u8| {
            TL.with(|tl| {
                let b = tl.base.get() as usize;
                b != 0 && (p as usize) >= b && (p as usize) < tl.end.get()
            })
        };
        assert!(
            in_arena(p1) && in_arena(p2),
            "in-scope allocs come from the arena"
        );
        assert!(p2 as usize >= p1 as usize + 128, "no overlap");
        assert_eq!(p1 as usize % 16, 0);
        // dealloc of an in-arena pointer is a no-op (doesn't free / crash).
        unsafe { ScopedAlloc.dealloc(p1, l) };
        // Finish the scope manually (as compile() does) and reset.
        let outer = leave_no_reset();
        assert!(outer);
        reset();
        // After reset the next in-scope alloc reuses the region.
        let scope2 = Scope::enter();
        let p3 = unsafe { ScopedAlloc.alloc(l) };
        assert_eq!(p3, p1, "reset hands back the same region");
        let _ = leave_no_reset();
        reset();
        drop(scope2);
        std::mem::forget(scope);
    }

    #[test]
    #[cfg_attr(miri, ignore)]
    fn pause_routes_to_system_then_resumes() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let l = layout(64, 8);
        let scope = Scope::enter();
        let paused = pause(); // routes to System, depth untouched
        let p_sys = unsafe { ScopedAlloc.alloc(l) }; // goes to System
        let in_arena = |p: *mut u8| {
            TL.with(|tl| {
                let b = tl.base.get() as usize;
                b != 0 && (p as usize) >= b && (p as usize) < tl.end.get()
            })
        };
        assert!(!in_arena(p_sys), "paused scope routes to System");
        unsafe { ScopedAlloc.dealloc(p_sys, l) };
        drop(paused); // pause lifted
        let p_arena = unsafe { ScopedAlloc.alloc(l) };
        assert!(in_arena(p_arena), "resumed scope bumps from the arena again");
        let _ = leave_no_reset();
        reset();
        std::mem::forget(scope);
    }

    /// A scope entered while paused (a compile run from inside an importer or
    /// warn handler) must nest under the live outer scope: leaving it is not
    /// "outermost", so it must not reset the arena the outer scope is using.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn nested_scope_while_paused_does_not_reset_outer_arena() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let l = layout(64, 8);
        let outer = Scope::enter();
        let p_outer = unsafe { ScopedAlloc.alloc(l) };
        let cursor_before = TL.with(|tl| tl.cursor.get());
        let paused = pause();
        let inner = Scope::enter();
        let p_inner = unsafe { ScopedAlloc.alloc(l) }; // paused -> System
        assert_ne!(p_inner, p_outer);
        assert!(!leave_no_reset(), "nested scope is not the outermost");
        reset(); // must be a no-op: depth is still 1
        std::mem::forget(inner);
        unsafe { ScopedAlloc.dealloc(p_inner, l) };
        drop(paused);
        assert_eq!(
            TL.with(|tl| tl.cursor.get()),
            cursor_before,
            "outer arena state intact"
        );
        let p_next = unsafe { ScopedAlloc.alloc(l) };
        assert_ne!(p_next, p_outer, "the outer block was not handed out again");
        let _ = leave_no_reset();
        reset();
        std::mem::forget(outer);
    }

    /// Threads that run one after another must share one region, not take a
    /// new 2 GiB reservation each.
    ///
    /// This is the shape that broke: the napi addon spawns a thread per async
    /// compile, and a reservation per thread grew the process by 2 GiB per
    /// compile — measured — until Linux refused the next `fork()` with ENOMEM
    /// and the host could not spawn a child at all.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn threads_that_follow_one_another_share_one_region() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let mut bases = Vec::new();
        for _ in 0..8 {
            bases.push(
                std::thread::spawn(|| {
                    let scope = Scope::enter();
                    let p = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
                    assert!(in_any_arena(p as usize), "the thread got an arena");
                    let base = TL.with(|tl| tl.base.get() as usize);
                    let _ = leave_no_reset();
                    reset();
                    std::mem::forget(scope);
                    base
                })
                .join()
                .unwrap(),
            );
        }
        bases.dedup();
        assert_eq!(
            bases.len(),
            1,
            "each thread took a fresh region instead of reusing the free one",
        );
    }

    /// …and its registry slot must come back too, or the cap is the same bug
    /// on a longer fuse: past `MAX_ARENAS` threads the claim fails, `reserve`
    /// gives up for good on that thread, and every later compile there runs on
    /// the system allocator — silently, at the speed this arena exists to fix.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn registry_slots_are_reusable_past_the_cap() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        for _ in 0..(MAX_ARENAS + 8) {
            std::thread::spawn(|| {
                let scope = Scope::enter();
                let p = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
                let arena = in_any_arena(p as usize);
                let _ = leave_no_reset();
                reset();
                std::mem::forget(scope);
                arena
            })
            .join()
            .unwrap();
        }
        // The last thread past the cap must still get an arena.
        let got = std::thread::spawn(|| {
            let scope = Scope::enter();
            let p = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
            let arena = in_any_arena(p as usize);
            let _ = leave_no_reset();
            reset();
            std::mem::forget(scope);
            arena
        })
        .join()
        .unwrap();
        assert!(got, "a thread past MAX_ARENAS still bump-allocates");
    }

    /// Slots are claimed by CAS, so the interesting case is threads racing for
    /// them. Each writes a pattern through its own arena pointer and reads it
    /// back: two threads handed the same region would corrupt each other.
    /// Afterwards the regions must be free to take again.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn concurrent_threads_get_disjoint_regions_and_release_them() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        // A barrier, because `spawn` does not mean "all at once": without one
        // an early finisher hands its region to a late starter, they are never
        // live together, and sharing is correct rather than a bug. Holding
        // them all at the same instant is what makes disjointness the question.
        let all_holding = std::sync::Arc::new(std::sync::Barrier::new(32));
        let threads: Vec<_> = (0..32u8)
            .map(|id| {
                let all_holding = all_holding.clone();
                std::thread::spawn(move || {
                    let scope = Scope::enter();
                    let l = layout(4096, 8);
                    let p = unsafe { ScopedAlloc.alloc(l) };
                    assert!(!p.is_null());
                    // SAFETY: 4096 writable bytes from this thread's arena.
                    unsafe { std::ptr::write_bytes(p, id, 4096) };
                    std::thread::yield_now();
                    // SAFETY: same allocation, still owned by this thread.
                    let seen = unsafe { std::slice::from_raw_parts(p, 4096) };
                    assert!(
                        seen.iter().all(|&b| b == id),
                        "another thread wrote into this thread's region",
                    );
                    let base = TL.with(|tl| tl.base.get() as usize);
                    all_holding.wait(); // nobody leaves until everyone is here
                    let _ = leave_no_reset();
                    reset();
                    std::mem::forget(scope);
                    base
                })
            })
            .collect();
        let mut bases: Vec<usize> = threads.into_iter().map(|t| t.join().unwrap()).collect();
        let held = bases.len();
        bases.sort_unstable();
        bases.dedup();
        assert_eq!(bases.len(), held, "two live threads shared a region");

        // And every one of them is available again: a thread now gets a region
        // that was held a moment ago rather than a thirty-third.
        let after = std::thread::spawn(|| {
            let scope = Scope::enter();
            let _ = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
            let base = TL.with(|tl| tl.base.get() as usize);
            let _ = leave_no_reset();
            reset();
            std::mem::forget(scope);
            base
        })
        .join()
        .unwrap();
        assert!(bases.contains(&after), "the released regions were not reused");
    }

    /// Allocating during TLS teardown must not panic.
    ///
    /// Dropping a thread-local frees whatever it owns, which allocates, and
    /// the arena's own state may already be gone by then — `with` panics on a
    /// destroyed slot, and a panic inside the global allocator aborts the
    /// process. `try_with` routes those late allocations to System instead.
    ///
    /// The guard below is touched BEFORE the arena, so it is destroyed after
    /// it: its `Drop` allocates with no arena state to find.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn allocating_while_the_thread_is_tearing_down_does_not_panic() {
        // Reserves a region too, so it must not run while another test is
        // watching the global count.
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        struct AllocsOnDrop;
        impl Drop for AllocsOnDrop {
            fn drop(&mut self) {
                // Straight through `ScopedAlloc`, NOT a `Vec`. These unit tests
                // do not install it as the global allocator, so a `Vec` here
                // would go to System and never reach the code under test — the
                // first version of this test passed just as happily with the
                // `TL.with` it was written to rule out.
                let l = layout(64, 8);
                // SAFETY: freed immediately below with the same layout.
                let p = unsafe { ScopedAlloc.alloc(l) };
                assert!(!p.is_null(), "a teardown allocation must still succeed");
                // SAFETY: from the call above, with the same layout.
                unsafe { ScopedAlloc.dealloc(p, l) };
            }
        }
        thread_local! {
            static LATE: std::cell::RefCell<Option<AllocsOnDrop>> =
                const { std::cell::RefCell::new(None) };
        }
        std::thread::spawn(|| {
            // Registered first => destroyed last, after the arena's state.
            LATE.with(|l| *l.borrow_mut() = Some(AllocsOnDrop));
            let scope = Scope::enter();
            let _ = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
            let _ = leave_no_reset();
            reset();
            std::mem::forget(scope);
        })
        .join()
        .expect("the thread tore down without panicking in the allocator");
    }

    /// More long-lived threads than there are slots must all get an arena, so
    /// long as they are not compiling at the same time.
    ///
    /// The lease is per COMPILE, not per thread. Held for the life of the
    /// thread — which is what `Drop` alone gave — a pool of `MAX_ARENAS`
    /// workers that had each compiled once would hold every slot forever, and
    /// every thread that arrived afterwards would run on the system allocator
    /// permanently, while all 128 of them sat idle. Silent, and for good.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn more_live_threads_than_slots_all_get_an_arena_in_turn() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let n = MAX_ARENAS + 2;
        // One compiles at a time; all of them stay alive to the end, which is
        // the shape a worker pool has.
        let turn = std::sync::Arc::new(std::sync::Mutex::new(()));
        let done = std::sync::Arc::new(std::sync::Barrier::new(n + 1));
        let threads: Vec<_> = (0..n)
            .map(|_| {
                let turn = turn.clone();
                let done = done.clone();
                std::thread::spawn(move || {
                    let got = {
                        let _one_at_a_time = turn.lock().unwrap_or_else(|e| e.into_inner());
                        let scope = Scope::enter();
                        let p = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
                        let got = in_any_arena(p as usize);
                        let _ = leave_no_reset();
                        reset();
                        std::mem::forget(scope);
                        got
                    };
                    done.wait(); // stay alive until every thread has compiled
                    got
                })
            })
            .collect();
        done.wait();
        let got: Vec<bool> = threads.into_iter().map(|t| t.join().unwrap()).collect();
        assert_eq!(
            got.iter().filter(|&&g| g).count(),
            n,
            "a live thread that had finished compiling was still holding its slot",
        );
    }

    /// A thread that arrives while every slot is taken must get the arena back
    /// once one frees, not spend the rest of its life on the system allocator.
    ///
    /// Before slots were reusable, "registry full" was a verdict and latching
    /// it was right. Now it is a moment — 128 other threads happened to be
    /// compiling — and latching it would quietly cost a long-lived worker
    /// every compile it ever runs.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn a_thread_that_found_the_registry_full_recovers_when_a_slot_frees() {
        let _serial = REGION_COUNT.lock().unwrap_or_else(|e| e.into_inner());
        let hold = std::sync::Arc::new(std::sync::Barrier::new(MAX_ARENAS + 1));
        let (seated_tx, seated_rx) = std::sync::mpsc::channel::<()>();

        // Fill every slot and hold them until the barrier opens.
        let holders: Vec<_> = (0..MAX_ARENAS)
            .map(|_| {
                let hold = hold.clone();
                let seated = seated_tx.clone();
                std::thread::spawn(move || {
                    let scope = Scope::enter();
                    let _ = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
                    seated.send(()).unwrap();
                    hold.wait();
                    let _ = leave_no_reset();
                    reset();
                    std::mem::forget(scope);
                })
            })
            .collect();
        for _ in 0..MAX_ARENAS {
            seated_rx.recv().unwrap();
        }

        // One thread, two compiles: the first finds nothing free, the second
        // runs after a slot has come back. Same thread on purpose — the point
        // is that the first answer is not remembered forever.
        let (answer_tx, answer_rx) = std::sync::mpsc::channel::<bool>();
        let (go_tx, go_rx) = std::sync::mpsc::channel::<()>();
        let probe = std::thread::spawn(move || {
            let attempt = || {
                let scope = Scope::enter();
                let p = unsafe { ScopedAlloc.alloc(layout(64, 8)) };
                let got = in_any_arena(p as usize);
                let _ = leave_no_reset();
                reset();
                std::mem::forget(scope);
                got
            };
            answer_tx.send(attempt()).unwrap();
            go_rx.recv().unwrap();
            answer_tx.send(attempt()).unwrap();
        });
        assert!(!answer_rx.recv().unwrap(), "no slot was free, so no arena");

        hold.wait(); // release the holders
        for h in holders {
            h.join().unwrap();
        }
        go_tx.send(()).unwrap();
        assert!(
            answer_rx.recv().unwrap(),
            "the same thread gets an arena once a slot comes back",
        );
        probe.join().unwrap();
    }

    /// A callback that panics must not leave the thread paused: the guard
    /// drops during unwinding, so a later compile on this thread bumps from the
    /// arena again instead of silently routing everything to System.
    #[test]
    #[cfg_attr(miri, ignore)]
    fn pause_guard_lifts_on_unwind() {
        let before = TL.with(|tl| tl.paused.get());
        let hook = std::panic::take_hook();
        std::panic::set_hook(Box::new(|_| {}));
        let result = std::panic::catch_unwind(|| {
            let _paused = pause();
            panic!("callback panicked");
        });
        std::panic::set_hook(hook);
        assert!(result.is_err());
        assert_eq!(TL.with(|tl| tl.paused.get()), before, "unwinding drops the guard");
    }
}
