# art-standalone_patched on Apple Silicon (aarch64-darwin): status and plan

This document records why the patched `art-standalone` (and therefore the whole
Android Translation Layer / NewPipe path) **cannot run on aarch64-darwin today**,
the evidence for that conclusion, and the plan for a proper arm64 port.

## TL;DR

5. ART requires its Java heap (and boot image) to live **inside the low 4 GB** of
   the address space, because it uses 32-bit "compressed" heap references
   *unconditionally*.
6. On Apple Silicon, macOS reserves the **entire low 4 GB** for every arm64
   process as `__PAGEZERO`. No arm64 process can map memory there, by any
   mechanism, and a binary that tries to opt out is killed by the kernel.
7. So the current arm64 build hangs in `Runtime::Init` — before the ATL ever
   creates a window. That is the "dock icon, no window" symptom.
8. The only macOS process type that *can* map the low 4 GB is x86_64 (under
   Rosetta 2), but nixpkgs 26.11 has dropped `x86_64-darwin`, so that escape
   hatch needs a second nixpkgs.
9. The proper fix is to **remove ART's requirement for a low-4 GB heap**. This
   document scopes that change.

## Symptom

Launching NewPipe:

- the Dock icon appears (that is GTK's macOS `NSApplication` starting), but no
  window is ever shown;
- `dex2oat` (spawned by the ATL to generate the framework boot image) runs for
  `570 s`, then trips its own watchdog:
  `A/dex2oat ... dex2oat did not finish after 570 seconds`;
- the ATL then logs `Could not create image space ... Attempting to fall back to
  imageless running` and **hangs anyway**, with no watchdog.

## Root cause

A stack sample of the stuck `dex2oat` (`sample <pid>`) shows the main thread
spinning in ART's linear **low-4 GB allocator**, never reaching window creation:

```
art::Runtime::Init
  → art::gc::Heap::Heap
    → art::MemMap::MapAnonymous
      → art::MemMap::MapInternal
        → art::MemMap::MapInternalArtLow4GBAllocator        (mem_map.cc:1020)
          → __msync                                          (1540/1550 samples)
```

In ATL's `main.c` the order is: `g_application_run()` (→ Dock icon), then
`create_vm()` (`src/main-executable/main.c:465`) boots ART, and only afterwards
`gtk_window_present()` (`:706`). Because `create_vm()` never returns, no window
is created.

### Why it spins instead of failing fast

`MapInternalArtLow4GBAllocator` (`art/libartbase/base/mem_map.cc:1020`):

1. scans low memory page by page from `next_mem_pos_` up to 4 GiB;
2. at each candidate it calls `TryMemMapLow4GB()` (`mem_map.cc:258`), which does
   `mmap(addr, …)` with `addr` as a **hint** and accepts the result only if the
   kernel returned exactly that address;
3. the fallback verifies free pages with `msync(page, kPageSize, 0)` (`:1080`)
   and retries the same hint mapping.

On Linux the low hint is honoured, so this returns almost immediately. On
macOS the hint is never honoured, so `TryMemMapLow4GB()` always fails and the
loop degenerates into an effectively unbounded scan that calls `msync` for
`length / 4 KiB` pages per step — hence the ~100 % CPU hang.

### Why ART needs the low 4 GB at all

Heap references are 32-bit and absolute (truncated), so every heap object and
the boot image must have an address below 4 GiB:

- `art/runtime/runtime_globals.h:86`
  `static constexpr size_t kHeapReferenceSize = sizeof(uint32_t);`
- `art/runtime/mirror/object_reference.h` — `mirror::HeapReference` stores
  `Atomic<uint32_t> reference_`, and
  `PtrCompression::Compress` is just
  `static_cast<uint32_t>(reinterpret_cast<uintptr_t>(ptr))` (i.e. truncate to
  32 bits); `Decompress` zero-extends back.
- Heap/space allocations hardcode `/*low_4gb=*/ true`:
  `gc/heap.cc:464,732`, `gc/space/bump_pointer_space.cc:33`,
  `gc/space/large_object_space.cc:142,361`, `gc/space/region_space.cc:63`,
  `gc/space/malloc_space.cc:113`, `gc/space/image_space.cc:942,953,1881`.
- `art/libartbase/base/mem_map.h:32` enables the linear allocator for
  `__APPLE__` / `__aarch64__` / `__mips__`:
  `#define USE_ART_LOW_4G_ALLOCATOR 1`.

There is **no** "uncompressed / 64-bit reference" mode in this ART: grepping the
whole tree finds no `UseCompressedReferences` / `kUse32BitPointerSize` toggle,
and `kHeapReferenceSize` is unconditionally 4.

## Why aarch64 macOS cannot provide low memory (evidence)

All measured on this machine (Darwin 24.x, Apple Silicon, 16 KiB pages).

| Probe | Result |
| --- | --- |
| arm64 `mmap(0x10000000, 64M, hint)` | relocated to `0x1027d4000` |
| arm64 `mmap(…, MAP_FIXED)` low 4 GB | `ENOMEM` (whole range scanned) |
| arm64 `mach_vm_allocate(VM_FLAGS_FIXED)` at `0x10000000` / `0x60000000` | `kr=1` (FAIL) |
| arm64 `mach_vm_map(VM_FLAGS_FIXED\|VM_FLAGS_OVERWRITE)` low | `kr=1` (FAIL) |
| arm64 `__PAGEZERO` = 0 / 0x4000 / 1 MiB / 1 GiB / 2 GiB | **SIGKILL (`rc=137`)** at load |
| arm64 `__PAGEZERO` = exactly 4 GiB | runs |
| arm64 `-no_pie` / `-image_base` (to keep `__TEXT` high) | ignored for arm64 |
| x86_64 (Rosetta) + `-Wl,-pagezero_size,0x4000`, low hint | **exact address**, across `0x10000000…0xe0000000` |

`otool -l .dex2oat-wrapped` confirms the shipped binary has
`segname __PAGEZERO / vmsize 0x0000000100000000` (4 GiB).

So the low 4 GB is a kernel-protected reservation for arm64 processes:
shrinking `__PAGEZERO` gets the process killed, and neither `mmap` nor Mach VM
can reclaim the region. Wine and OpenJ9 hit the same wall (see References); the
industry answer for "needs low memory" guests on Apple Silicon is Rosetta
(x86_64), which is exactly why the x86_64 route exists.

## Upstream status: the aarch64 screenshot is aarch64 **Linux**, not macOS

Upstream ATL is a Linux project ("a translation layer that allows running
Android apps on a Linux system"). Its `screenshot_2.png` caption is
"Oculus Quest version of BeatSaber running on an aarch64 laptop" — an
Apple-Silicon laptop running **Linux** (e.g. Asahi), where the low 4 GB is
available. There is no upstream macOS support; the macOS port is ours, so
"upstream has an aarch64 screenshot" says nothing about aarch64-darwin.

The README's "On Apple Silicon" note is about the **16 KiB page size**, not the
low-4 GB problem, and suggests forcing the interpreter:

```sh
-X '-Xnoimage-dex2oat' -X '-Xusejit:false'   # (clear ~/.cache/art/ too)
```

This was tested against our build (fresh `HOME`, empty ART cache). It does
disable image compilation — the log shows
`Could not create image space with image file ...: Image compilation disabled`
and falls back to imageless running — but the process **still hangs in exactly
the same place**:

```
Runtime::Init → Heap::Heap → MapInternalArtLow4GBAllocator → __msync   (1661/1699 samples)
```

because the heap allocation requests `low_4gb` unconditionally, independent of
image/JIT/interpreter configuration. So the upstream workaround fixes a
different (page-size) problem and does not help on aarch64-darwin.

## Options considered

| # | Option | Verdict |
| --- | --- | --- |
| A | Shrink `__PAGEZERO` and map low on arm64 | **Impossible** — kernel SIGKILLs the binary |
| B | Reclaim the low 4 GB via Mach VM / `MAP_FIXED` | **Impossible** — `kern_return_t` failure / `ENOMEM` |
| C | Build the whole stack for `x86_64-darwin`, run under Rosetta | Works at the OS level, but nixpkgs 26.11 **dropped `x86_64-darwin`**; needs a second nixpkgs (`26.05-darwin`) |
| D | **Stop ART from needing a low-4 GB heap** | The proper arm64 fix — scoped below |

## Chosen approach (D): drop the low-4 GB heap requirement

Two designs; both keep the rest of ART intact.

### D1 — base-relative compressed references (HotSpot-style)

Keep 4-byte refs, but make them an **offset from a base** instead of an absolute
truncated address:

- `PtrCompression::Compress(p) = (uint32_t)((uintptr_t)p - base)`
- `PtrCompression::Decompress(r) = (void*)(base + (uintptr_t)r)`

Then the heap/image may live anywhere as long as `base` is a fixed address
(e.g. the boot-image base, or a reserved region) and object addresses stay
within 4 GiB of it.

- Pros: `kHeapReferenceSize` stays 4; `mirror::Object` layout unchanged; image
  format unchanged in size; C++ code that goes through `Compress`/`Decompress`
  keeps working.
- Cons: **every site that materialises a raw ref into a pointer must add the
  base**, i.e. the ARM64 code generator, the interpreter (mterp templates), the
  quick-entrypoint assembly, and a handful of hand-written C++ spots.

### D2 — 64-bit (uncompressed) references

Make `kHeapReferenceSize = sizeof(uintptr_t)` and `HeapReference` store a real
pointer.

- Pros: no base plumbing.
- Cons: changes object layout, the image format, JNI/JNIEnv layouts, and every
  ref load/store in the interpreter and code generators; this is the mode AOSP
  removed years ago, so there is no parameterised support left to lean on.

**D1 is the smaller, more tractable change** and is the one to pursue first,
scoped to the pieces needed to run arm64 host code.

### Scope of D1 (to be confirmed during implementation)

Places that read/write a raw heap reference and must apply the base:

- `art/runtime/mirror/object_reference.h` — `PtrCompression` (the core change);
- `art/compiler/optimizing/code_generator_arm64.{cc,h}` (and the other arch
  generators only if those targets are built) — Load/StoreReference and GC
  barriers;
- `art/runtime/interpreter/mterp/` templates + `mterp.cc`;
- `art/runtime/entrypoints/quick/` (arm64 quick entrypoints / stubs);
- boot image writer/reader: `art/runtime/gc/space/image_space.cc`,
  `art/dex2oat` image writer;
- `art/runtime/gc/` barriers and `card_table`/`remembered_set` ref handling;
- JNI local/global reference tables (`art/runtime/jni/`);
- `art/libartbase/base/mem_map.{h,cc}` — stop forcing `low_4gb` and drop the
  linear allocator path on darwin.

Guard the whole thing behind a single compile-time switch (e.g.
`ART_USE_RELATIVE_REFS` / a `-D` in the darwin-host build) so Linux behaviour is
untouched.

### Scope of D1, enumerated

Central change (makes all C++ users of references work automatically):

- `art/runtime/mirror/object_reference.h` — `PtrCompression::Compress` /
  `Decompress` is the **single** C++ encoder/decoder, used by
  `HeapReference`, `CompressedReference`, `GcRoot`, the JNI reference tables,
  the image roots visitor and the GC barriers. `kHeapReferenceSize` stays 4.
- a process-wide `base`: `art/libartbase/base/mem_map.{h,cc}` must stop forcing
  `low_4gb` on darwin (map the heap above 4 GiB) and the caller must pin
  image + heap so every object stays within 4 GiB of `base`.

Raw-reference sites that bypass `PtrCompression` and must apply `base`:

- arm64 code generator — `art/compiler/optimizing/code_generator_arm64.cc`:
  `Load` (`:1464`, ref case `:1482` → `__ Ldr dst, src`),
  `Store` (`:1577`, ref case `:1591` → `__ Str src, dst`),
  `LoadAcquire` / `StoreRelease`, `HandleFieldGet` / `HandleFieldSet`
  (`HeapOperand`, `:1870…`), Baker read barrier
  `GenerateFieldLoadWithBakerReadBarrier`, `MaybeGenerateReadBarrierSlow`,
  object-array element access (`:3742`, `:3901`).
- interpreter — `art/runtime/interpreter/mterp/arm64/*.S`
  (`object.S`, `array.S`, `invoke.S`, `main.S`): the `%def op_iget / op_iput /
  op_aget-object` templates load a ref with `ldr wN,[…]` and use it as a
  pointer (`UNPOISON_HEAP_REF`); plus `mterp.cc:848`.
- quick-entrypoint assembly — `art/runtime/arch/arm64/`
  (`quick_entrypoints_arm64.S`, `jni_entrypoints_arm64.S`,
  `asm_support_arm64.S`) and `entrypoints_init_arm64.cc`.
- boot image — writer `art/dex2oat/linker/image_writer.cc`
  (`sizeof(mirror::HeapReference<Object>)` `:1456`, `native_object_relocations_`,
  `HeapReferencePointerInfo`) and reader `gc/space/image_space.cc`
  (ref fixups `:435…`, `:942`, `:953`); the stored image must hold relative refs.

Size signal: `kHeapReferenceSize` appears in only ~15 files and
`PtrCompression` is the only C++ codec, so the bulk of the work is the arm64
codegen + mterp + quick-entrypoint **assembly**, not wide C++ surgery. That is
why D1 (keep 4-byte refs, add a base) beats D2 (widen refs to 8 bytes, which
would also change object layout and the on-disk image format).

### Choke points — and why this is still a large change

The C++ side has a real single choke point:

- **all C++ code** — `PtrCompression::Compress` / `Decompress`
  (`runtime/mirror/object_reference.h`) — **done** (core patch).

The **assembly** side does *not*, and this is the crux. A 32-bit reference slot
(register file / object field / stack slot / boot image) cannot hold
`base + offset` when `base >= 4 GiB`, so what gets stored is the **offset**.
That means the base must be added at **every place a reference is dereferenced
as an address**, and it therefore *cannot* be folded into
`UNPOISON_HEAP_REF` (mterp) or `MaybeUnpoisonHeapReference` (codegen): the
unpoisoned value is written straight back into a 32-bit slot — e.g. `op_iget_object`
does `ldr w0,[x2,x1]; UNPOISON_HEAP_REF w0; …; SET_VREG_OBJECT w0,w2`, and `x2`
itself came from `GET_VREG`, i.e. it holds an offset and needs `+base` before
`[x2,x1]`.

So D1's asm surface is scattered, not a few macros:

- mterp arm64 — every `ldr/str [xObj, …]` dereference: `op_iget*`, `op_iput*`,
  `op_aget*`/`op_aput*`, invoke receivers, `op_iget_quick`, … in `object.S`,
  `array.S`, `invoke.S`, `main.S`. (Array object get/put go through the C++
  helpers `artAGetObjectFromMterp` / `MterpAputObject`, which are already safe
  via `PtrCompression`.)
- arm64 codegen — every ref used as a base: `HandleFieldGet`/`Set`,
  `HandleArrayGet`/`Set`, invoke receiver, the read-barrier slow paths; and the
  `LocationSummary` handling, since reference locations are 32-bit W registers.
- quick entrypoints — `runtime/arch/arm64/*.S`.

Two ways, both large:

- **D1** — add the base at every dereference (a `add tmp, ref, base` before the
  load/store), keeping 32-bit refs and the image format;
- **D1'** — hold *in-register* references as 64-bit absolute pointers and only
  compress at memory/image boundaries; cleaner at dereference sites but changes
  `LocationSummary`/register allocation for references.

Note on config: the ATL's own Apple-Silicon setting
(`-Xusejit:false -Xnoimage-dex2oat`, from the upstream README) makes the first
working target **interpreter-only**, which drops the codegen and image work from
the first iteration but not the mterp/entrypoint work.

The remaining edits are assembly and cannot be proven correct without compiling
and running ART (a long build), so converging them needs a build loop.


## Progress: the low-4 GB hang is fixed (branch state)

`art-standalone_patched` is built with `-DART_USE_RELATIVE_REFS=1` and the
`darwin-arm64-*` patches. The build succeeds (via the `vixl` workaround below).

- **Before**: `dex2oat`/the ATL spun forever in `msync` inside
  `MapInternalArtLow4GBAllocator` (1540/1550 samples) and produced nothing.
- **Now**: `dex2oat` gets past `Runtime::Init`, maps the heap in the reference
  window (e.g. `[0x300000000, 0x400000000)`), and produces `boot.oat` +
  `boot.vdex`. The `msync` hang is gone.

**Fixed**: `dex2oat` now runs to completion — `rc=0`, writing `boot.art`,
`boot.oat` and `boot.vdex`. Along the way:

- the image base now follows the runtime window — `ArtBaseAddress()` returns
  `g_reference_base` (`darwin-arm64-relative-refs-image-base.patch`) instead of
  the fixed `ART_BASE_ADDRESS`, so the host image is built inside the window
  (the previous `darwin-arm64-relative-refs-base.patch`, which pinned a fixed
  `LIBART_IMG_HOST_BASE_ADDRESS`, is superseded and was removed);
- the GC card table, which was hard-sized to cover `[4 KB, 4 GB)`
  (`darwin-arm64-relative-refs-heap.patch`) — with a heap at 12 GiB every
  `CardFromAddr` was out of bounds;
- the interpreter's `UnstartedRuntime` JNI shims read an object argument slot
  with `reinterpret_cast32<mirror::Object*>(args[n])`, treating a compressed
  reference as an absolute low-4-GiB pointer; with relative refs the slot is an
  *offset*, so this dereferenced `0x3da68`.
  `darwin-arm64-relative-refs-unstarted.patch` adds an `UnstartedArgObject()`
  accessor that adds `g_reference_base`, used at all 11 such sites.

### Known open issue: base reconciliation across processes

`g_reference_base` is chosen per process by the `mmap(NULL)` probe, but the boot
image stores references as *offsets from the build-time base*. The `dex2oat` that
writes the image and the process that later loads it generally pick different
bases, so a cached image will decode wrong unless the loader adopts the build
base (nothing currently sets `g_reference_base` from the image header). That must
be resolved before an end-to-end (ATL) run that reuses a boot image.

### Localized crash point (via unbuffered file tracing)

`lldb`/core dumps are unavailable, so a temporary trace was added with
`fopen`/`fputs`-to-a-fixed-file markers (writing to fd 2 is redirected by ART
mid-startup, so it is unreliable). The markers localize the segfault to:

```
dex2oat → Setup() → CreateRuntime() → Runtime::Create() → Runtime::Init()
  → gc::Heap::Heap(...)
  → the main-space mapping  (between the non-moving space setup and the
                             card-table creation)
```

So it is not codegen and not the image writer — it is the heap's own space
allocation. Root cause confirmed by testing:

- `TryMemMapLow4GB` was applying `MAP_FIXED` on the unguarded **first** attempt
  (before the msync free-check), clobbering live memory → segfault. Making
  `MAP_FIXED` conditional on the free-checked path
  (`darwin-arm64-relative-refs-alloc.patch` now passes `use_fixed`) turns the
  segfault into a **hang**: the free-check then finds the fixed window already
  occupied and the allocator falls back to the original slow page-scan.
- The real blocker is the window address: no *fixed* 4 GiB-aligned base is
  reliably free on macOS. `0x200000000` (8 GiB) is occupied (hang), and
  `0x1000000000` (64 GiB) is also occupied (segfault). A reliable fix needs a
  **dynamically reserved** window (or a base verified free at startup), with the
  base plumbed through `PtrCompression` and mterp instead of a compile-time
  constant.

(Tracing tools unavailable in this sandbox: `lldb` (task_for_pid denied), core
dumps (`/cores` stays empty), macOS crash reports, and a `DYLD_INSERT_LIBRARIES`
SIGSEGV handler — the last perturbs ART's own use of SIGSEGV.)

## Upstream reconciliation (after `git pull`)

The pull refactored the base `art-standalone` package, folding most of the darwin
patches into it (new per-fix patches: `agent`, `backtrace`, `check_jni`,
`dex2oat`, `fake_log_device`, `jni_internal`, `parsed_options`, `runtime_dladdr`,
`runtime_offsetof`, `writer`, `no-hardcode-path-addr2line`).  Our
`art-standalone_patched` duplicated them and stopped applying, so the duplicated
file sections were dropped from `darwin-art-runtime.patch` (`agent.cc`,
`check_jni.cc`, `dex2oat.cc`, `parsed_options.cc`, `runtime.cc`, `runtime.h`)
and `darwin-system.patch` (`fake_log_device.c`); the upstream versions now
provide those changes.

The one exception is `jni_internal.cc`: upstream's `jni_internal.patch` only
covers the `const jvalue*` changes (from ~line 1061) and does **not** delete the
`CHECK(libjavacore_loaded_)` / `CHECK(libnativehelper_loaded_)` /
`CHECK(libopenjdk_loaded_)` checks — which compare `libjavacore.so`-style names
(`EndsWith`) against the `*.dylib` host libs — so that hunk stays in
`darwin-art-runtime.patch`.

Also, the unpinned nixpkgs channel now marks `vixl` broken, which blocked
evaluation; `art-standalone_patched` clears the flag in `vixl_patched`
(`meta.broken = false`) so the build evaluates. It compiles and links fine.

### Resolved (dynamic window + page size), current state

The fixed-window approach could not work, so `g_reference_base` is now chosen at
RUNTIME (`ReserveReferenceWindow()` in `mem_map.cc`): probe an 8 GiB free region
with `mmap(NULL, …)`, take the 4 GiB-aligned half, release the probe, and map the
heap there. `PtrCompression` and mterp read the base from a global
(`art::g_reference_base` / `art_get_reference_base()`). This got `Heap::Heap` past
the main-space mapping.

Two more darwin fixes were needed to finish the heap and boot the runtime:

- **Page size** (`darwin-arm64-page-size-mprotect.patch`): ART's heap does
  `mprotect`/`madvise` at `kPageSize` (4 KiB) granularity, which macOS rejects
  (`EINVAL`) on 16 KiB pages. The affected sites now align to the host page.
- **Quick entrypoints** (`darwin-arm64-quick-entrypoints.patch`): upstream stubs
  `ResetQuickAllocEntryPoints` for `__APPLE__ && __LP64__`; its two callers
  (`Heap::ChangeAllocator`, `DefaultInitEntryPoints`) now skip it on Apple.

With these, `dex2oat` initializes the heap and the class linker (`Heap::Heap` and
`Runtime::Init` both complete) and now fails later, in **class loading**:

```
E/dex2oat: Failed to return pre-allocated NoClassDefFoundError
A/dex2oat: thread.cc:4220] Check failed: new_exception != nullptr
```

A class lookup fails and the pre-allocated `NoClassDefFoundError` cannot be
returned. Without `-verbose:class` this shows as `Failed to return pre-allocated
NoClassDefFoundError` (`thread.cc:4220 Check failed: new_exception != nullptr`);
with `-verbose:class` the same underlying corruption surfaces as a low-address
segfault during class linking:

```
Fatal signal 11 (SIGSEGV), code 2 (SEGV_ACCERR) fault addr 0x3da68   # < 4 GiB, PROT_NONE
... Beginning verification for class: java.lang.Integer
... Loaded class [Ljava/lang/Integer;
```

A fault address that low (inside the arm64 `__PAGEZERO`) was a reference
**offset** used as an address. The culprit was
`interpreter::UnstartedRuntime::Jni` →
`UnstartedJNIUnsafeGetArrayBaseOffsetForComponentType`, whose
`reinterpret_cast32<mirror::Object*>(args[0])` treated the interpreter's
compressed argument slot as an absolute pointer. Localized with a temporary
`dladdr`-based diagnostic in `runtime_common.cc`'s crash dumper (`lldb` and core
dumps are unavailable here) and fixed by
`darwin-arm64-relative-refs-unstarted.patch`.

## Plan

1. **Reproduce / lock the diagnosis** — done (this file).
2. **Spike D1 end-to-end on arm64**: introduce the base, wire it into
   `PtrCompression`, and get `dex2oat` to build a boot image + ART to boot the
   framework with the interpreter, forcing the heap high. Start with
   interpreter-only (`-Xint`) to avoid the code-generator work, then extend to
   the JIT.
3. **Land behind a flag** so the existing Linux build is unaffected.
4. **Re-enable the ATL `newpipe` run** and confirm a window appears.

Open question to settle in step 2: whether the arm64 quick entrypoints can be
left alone initially (interpreter-only) or must change immediately.

## References

- Apple: "macOS 11 ARM64: allocate memory in 32-bit address space" —
  <https://developer.apple.com/forums/thread/655950>
- WineHQ: "Native arm64 macOS direction: low 4GB, x18, and layout work" —
  <https://list.winehq.org/hyperkitty/list/wine-devel@list.winehq.org/message/2WWSHLWFTPASROXDF6HRP3VZUKYJAWNF/>
- Wine: "Support running on Apple Silicon macOS with native WOA" —
  <https://list.winehq.org/hyperkitty/list/wine-gitlab@list.winehq.org/message/IGUYCARNB3UPJYSKG5CA7JVYIZYDK7SJ/>
- OpenJ9 `pagezero_size` handling —
  <https://github.com/ibmruntimes/openj9-openjdk-jdk25/commit/0235a9197ffdd1e185f257862d738b61fa0298b0>
