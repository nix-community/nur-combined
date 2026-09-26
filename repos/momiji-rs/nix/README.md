# sasso for Nix

Users don't need anything here: `nix run github:momiji-rs/sasso -- --version`
works because the repo root is a flake. This directory is the packaging itself,
and the notes for keeping it honest.

| file | what it is |
| --- | --- |
| `package.nix` | the `sasso` CLI derivation the root `flake.nix` builds |
| `ffi.nix` | the C ABI as a package — `libsasso.{so,dylib}`, `libsasso.a`, `sasso.h`, a `.pc` file |
| `nur.nix` | the NUR entry point — the two above, as `nur.repos.momiji-rs.*` |
| `nixos-vm/` | a throwaway NixOS guest that installs sasso for real and says PASS or FAIL |

The flake exposes both: `packages.sasso` (`default`) and `packages.sasso-ffi`,
plus `overlays.default` so a NixOS or nix-darwin configuration gets `pkgs.sasso`
and `pkgs.sasso-ffi` before either lands in a nixpkgs channel. Rust callers want
neither — they take the crate from crates.io through their own `Cargo.lock`.

## Checking a change

```console
$ nix flake check -L        # what CI runs
$ nix build .#sasso && ./result/bin/sasso --version
$ nix develop               # the toolchain CI uses, dart-sass included
```

`nix flake check` is three derivations, and between them they cover more than a
compile:

- **`sasso`** — the CLI. Building it runs the full `cargo test` suite, because
  the suite needs no network: `tests/parity.rs` shells out to dart-sass only
  under `SASSO_PARITY=1`. `versionCheckHook` then runs `sasso --version` and
  checks it against the version in `Cargo.toml`.
- **`sasso-ffi`** — the C ABI. Its install check drives the *installed* library —
  `libsasso.so` or `libsasso.dylib`, whichever the platform builds — through
  `ffi/examples/smoke.py`, so it tests what a consumer links against rather than
  a build-tree artifact.
- **`dart-compat`** — issue #82's acceptance criteria: the dart-compatible flag
  set (`--no-error-css --stop-on-error --no-color --quiet --quiet-deps
  --style=compressed --no-source-map in.scss:out.css`) compiles, and the bytes
  match what dart-sass emits for the same input. The oracle is nixpkgs'
  dart-sass, pinned by our `flake.lock`, so only a deliberate lock bump can move
  it — which is exactly when a divergence is worth hearing about.

What it cannot cover is the part that needs a machine: a real NixOS activating a
system profile, and `nix run` against a URL from a host that has never seen this
tree. That is `nixos-vm/`.

## The end-to-end run

```console
$ cd nix/nixos-vm
$ sudo ./run.sh                                  # the published flake
$ sudo SASSO_FLAKE=/path/to/checkout ./run.sh    # a local tree
```

Boots a NixOS guest under firecracker (via [microvm.nix]) on a Linux host with
`/dev/kvm`, and checks, in the guest: `sasso` on `PATH` from
`environment.systemPackages` via our overlay, `--version` matching the flake, the
dart-compatible flag set, a stylesheet error exiting non-zero, `pkg-config
--libs sasso` plus a C program that links and runs against `libsasso`, then
`nix run` and `nix profile add` straight from the flake URL. Prints PASS or FAIL
and exits accordingly. A PASS deletes its own scratch directory in `/tmp`, out-link
and guest store image included; a FAIL keeps it and points at the console log.
`KEEP_RUNDIR=1` keeps it either way.

Measured on Linux/x86_64: just under four minutes from boot to verdict, nearly
all of it the guest compiling sasso from the flake URL, plus the host-side build
of the guest itself — seconds when it is already in the store, several minutes
when a changed `package.nix` means rebuilding sasso twice.

Worth running when the flake's *outputs* change shape (a new package, a changed
overlay, a nixpkgs bump that moves `buildRustPackage`), and before a nixpkgs
submission. Not worth running for a code change — `nix flake check` covers that.

[microvm.nix]: https://github.com/astro/microvm.nix

## The NUR channel

`nur.nix` is this repo's entry point for the [Nix User Repository][NUR], so that
a configuration can name a package rather than a flake URL:

```nix
environment.systemPackages = [ pkgs.nur.repos.momiji-rs.sasso ];
```

**Registration is not merged yet**, so `nur.repos.momiji-rs` does not resolve for
anyone but us — until it does, the flake above is the only way in, and the line
here and in the top-level README should stay unadvertised. The entry asks NUR to
point at **this repository** rather than at a separate `nur-packages` one:

```json
"momiji-rs": {
    "url": "https://github.com/momiji-rs/sasso",
    "file": "nix/nur.nix",
    "github-contact": "linyiru"
}
```

That is what keeps the channel from rotting. A `nur-packages` repo would have to
carry the nixpkgs shape below — a tag, a literal version, a `cargoHash` — and so
a second edit every release; `nur.nix` re-exports derivations that build the tree
they live in, so a release bumps `Cargo.toml` and the channel follows. The
`momiji-rs` key is a name NUR lets us pick rather than the repo owner (92 of the
574 entries in `repos.json` differ from theirs, counted 2026-09-17), so if a
second package ever needs its own repo, that is a one-line change on their side
and no user's `nur.repos.momiji-rs.sasso` breaks.

NUR re-locks once a day on its own. To not wait, after pushing a release:

```console
$ curl -XPOST https://nur-update.nix-community.org/update?repo=momiji-rs
```

Before touching `nur.nix`, run NUR's own evaluation check from the repo root. It
catches what `nix build` cannot, because it forbids eval-time network access —
the failure NUR is most often asked about:

```console
$ nix-env -f nix/nur.nix -qa \* --meta --drv-path --show-trace \
    --option restrict-eval true --option allow-import-from-derivation true \
    -I nixpkgs=$(nix-instantiate --find-file nixpkgs) -I ./
```

It must list `sasso` and `sasso-ffi`. A red evaluation is silent by design: NUR
keeps the last revision that evaluated, so users just quietly stay on an older
sasso — which is why the `nix flake` CI job runs this same check on every push
rather than leaving it to be remembered.

[NUR]: https://github.com/nix-community/NUR

## The nixpkgs submission

nixpkgs does not carry sasso. [NixOS/nixpkgs#564362] added
`pkgs/by-name/sa/sasso/package.nix` and was closed unmerged on the maturity
questions in nixpkgs' own `pkgs/README.md` — ready for general use, a realistic
chance of being used by other people — with NUR suggested for the time being,
which is what `nur.nix` above is. Reopening is invited once the project has more
of a track record, so these notes stay put.

The derivation that PR carried differs from `package.nix` here on purpose:

|  | here | nixpkgs |
| --- | --- | --- |
| source | `lib.cleanSource ../.` | `fetchFromGitHub` at the tag |
| version | read from `Cargo.toml` | literal, rewritten by the bot |
| crates | `cargoLock.lockFile` | one `cargoHash` |
| `passthru.updateScript` | none | `nix-update-script { }` |

That shape is not a preference: `nix-update` and the r-ryantm bot that follows
our tags know how to rewrite exactly those fields, and a package they can update
is one nobody has to remember. Keep the judgement calls — the license pair, the
check story, `meta` — identical between the two.

Rebuilding it for a resubmission, from a nixpkgs checkout:

```console
$ nix run nixpkgs#nix-update -- --version 0.14.1 sasso   # src hash + cargoHash + version
$ nix-build -A sasso && ./result/bin/sasso --version
$ nix run nixpkgs#nixpkgs-review -- wip                  # what a reviewer will see
```

Two things nixpkgs asks for that are easy to miss:

- commits are `sasso: init at 0.14.0` / `sasso: 0.14.0 -> 0.14.1` — the prefix
  drives their CI, and a maintainer addition is its own commit
  (`maintainers: add …`, validated by `nix-build lib/tests/maintainers.nix`);
- anything LLM-assisted needs an `Assisted-by:` trailer naming the tool and
  model, per their CONTRIBUTING; `Co-authored-by:` explicitly does not count.

[NixOS/nixpkgs#564362]: https://github.com/NixOS/nixpkgs/pull/564362
