# swift6-jen20 — Swift 6.2.4 (nixpkgs WIP)

Swift **6.2.4** packaged from the Nixpkgs Swift Matrix WIP, not from nixpkgs `master` (still on 5.10.x). Attribute name keeps the Matrix nick (`jen20`) for provenance while making clear this is a Swift 6 toolchain.

## Sources

| Piece | Where it came from |
| --- | --- |
| Package set / version `6.2.4` | [reckenrode/nixpkgs](https://github.com/reckenrode/nixpkgs) branch `swift-update-mk2`, commit [`9bd6cfed336853908d93c95c21f39e0255ac409c`](https://github.com/reckenrode/nixpkgs/tree/9bd6cfed336853908d93c95c21f39e0255ac409c) — `pkgs/development/compilers/swiftPackages/` and `pkgs/top-level/swift-packages.nix` |
| `hostPlatform.swift` elaboration | Same commit, `lib/systems/default.nix` (injected in our `swift-packages.nix` because stock nixpkgs lacks it) |
| Linux `swift-corelibs-icu` | Vendored [reckenrode mk2 `darwin/ICU`](https://github.com/reckenrode/nixpkgs/tree/9bd6cfed336853908d93c95c21f39e0255ac409c/pkgs/os-specific/darwin/by-name/ic/ICU) (`./ICU`) — Apple ICU with Linux `libicucore` (stock nixpkgs ICU is insufficient for Foundation) |
| Linux REPL resource dir, REPL `SDKROOT` wrapper, Linux sysroot, stronger REPL test | [jen20 gist `3b797f020ee81dc564e768f1670ced90`](https://gist.github.com/jen20/3b797f020ee81dc564e768f1670ced90) (Matrix: jen20 aarch64-linux smoke tests) |
| C++ interop archives + `swiftrt.o` (`llc -relocation-model=pic` bitcode → native) + re-enable stdlib LTO | Randy Eckenrode on `swift-update-mk2` / Matrix (Swift has no FatLTO; `swift-frontend` ignores `-ffat-lto-objects`); we also convert `swiftrt.o` with PIC so non-LTO PIE links (e.g. Foundation cmake checks) work |
| Related REPL test hardening | [booxter/nixpkgs `fix-swift-repl`](https://github.com/booxter/nixpkgs/commits/fix-swift-repl/) (Ihar Hrachyshka) |

Local edits vs upstream snapshot: drop LLDB Debug/MSan WIP flags from the mk2 tip; wire the gist/Matrix fixes above; adapt `by-name-overlay.nix` to take `lib` as an argument; link `clangBasic` from `swiftBasic` (`0011-link-clangBasic-from-swiftBasic.patch`) so external-Clang builds resolve `DarwinSDKInfo` when linking tools like `swift-scan-test`.

## Use

```nix
# toolchain
nur.repos.mio.swift6-jen20

# package set
nur.repos.mio.swift6-jen20.passthru.swiftPackages
```

Expect long bootstrap builds. Upstream still iterating (stdlib layout, REPL module paths, eventual Swift 6.3 bootstrap). Matrix channel topic tracks Darwin/Linux status and the live WIP branch.
