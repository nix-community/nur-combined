# sasso Ruby gem — implementation plan

> Native-extension gem (magnus + rb-sys), precompiled, RubyGems Trusted Publishing.
> Produced by a 5-agent research workflow (2026-06-13), verified against the repo.
> Path A (in-process `Sasso.compile`); a `sasso-rails` gem layers on top later.

## ⚠️ REPO-LAYOUT DECISION — REVISED after a second research pass (2026-06-13)

A follow-up WebSearch-grounded study **overturned this plan's "in-repo `ruby/`
+ `path` dependency" assumption.** Corrected decision:

> **The gem lives in a SEPARATE repo `momiji-rs/sasso-ruby`, and `ext/sasso/Cargo.toml`
> depends on the PUBLISHED crate `sasso = "=X.Y.Z"` from crates.io — NOT a `path` dep.**

Why (all verified live, not from memory):
- **`grass-ruby`** — the exact analog (a pure-Rust Sass compiler wrapped via
  magnus+rb-sys) — is a separate repo depending on `grass_compiler` from
  crates.io. So are **wasmtime-rb** (`wasmtime = "=45.0.0"`), **ankane/ruby-polars**
  (`polars = "=0.54.4"`), **ankane/tokenizers-ruby** (`=0.23.1`), **commonmarker**/
  **selma**. **Zero** verified examples of a same-owner Rust-core + rb-sys gem in
  the core monorepo via a path dep.
- **`cargo publish` refuses path-only deps**, and a *source* gem compiles on the
  end-user's machine — so a shipped gem can't carry an unresolved `path` dep
  pointing outside its payload. sasso v0.3.0 is already on crates.io, so the
  exact-pin crates.io dep is free + clean (no vendoring / publish-time rewrite).
- **Release decoupling**: the gem tags itself on its own cadence (bump the `=`
  pin when you choose); a `sasso` core release does NOT drag the heavy
  cross-platform fat-gem matrix.

**Unchanged**: the native-extension *architecture* below (magnus + rb-sys,
`ext/sasso/` layout, the `Sasso.compile` API, the §2 skeletons) is correct —
only (a) it moves to the separate repo, (b) `ext/sasso/Cargo.toml` uses
`sasso = "=0.3.0"` instead of `path = "../../.."`, (c) no root-`Cargo.toml`
workspace-exclude edit is needed, and (d) the release workflow lives in the gem
repo (gem-owned `v*` tag, **floating** gem version + **exact `=`** core pin — the
ankane pattern). **`wasm/` stays in THIS repo** (same-toolchain first-party
artifact); the Ruby gem is the well-precedented exception that goes external.

Everything from "## 0" down is the original in-repo plan; read it for the
binding mechanics + skeletons, applying the four deltas above.

---

# Implementation Plan: `sasso` Ruby native-extension gem (magnus + rb-sys, precompiled, RubyGems Trusted Publishing)

## 0. Ground truth (verified against the repo @ `36abc7c`)

These were checked in-tree, not assumed:

- **Core API** (`src/lib.rs`): `pub fn compile(source: &str, options: &Options<'_>) -> Result<String, Error>`. `Options<'a>` has public fields + the builders `with_style/with_syntax/with_importer/with_url/with_unicode`. `OutputStyle::{Expanded(default),Compressed}`, `Syntax::{Scss(default),Sass,Css}`.
- **`FsImporter`** is public and exported: `pub fn new(load_paths: Vec<PathBuf>) -> Self`. Takes an **owned `Vec<PathBuf>`** (not a slice) — the research said "slice"; it's `Vec`. It lives in the core crate, so the gem can use it with zero callback risk.
- **`Error`** (`src/error.rs`): `pub message: String`, `pub line: usize`, `pub col: usize`; `length`/`rendered` are `pub(crate)`. `impl Display` renders the **full dart-style diagnostic block** when `rendered` is set, else the legacy one-liner. Derives `Clone`, impls `std::error::Error`. So `e.to_string()` is the exact thing the CLI prints.
- **Allocator** (`src/main.rs:30`): `#[global_allocator] static GLOBAL: sasso::ScopedAlloc` is **only** in the binary. `src/lib.rs` installs nothing. `compile()` deep-clones its result to the system allocator before resetting the arena, and is documented correct under any global allocator. ⇒ **The gem must NOT install a `#[global_allocator]`.**
- **`url` is load-bearing** (confirmed in `compile_inner`): byte-exact diagnostic snippets are emitted only when `options.url` is `Some`. Without it, errors are the legacy `Error: <msg> (line:col)`.
- **Workspace convention**: root `[workspace] exclude = ["wasm"]`; root package `exclude = ["/bench","/spec","/docs","/.github","/wasm"]`; `wasm/Cargo.toml` carries its OWN empty `[workspace]` table with the documented worktree-walk comment. Core lints: `unsafe_code = "deny"` (not forbid).
- **Workflows**: `actions/checkout@v6`, `actions/setup-node@v6`, top-level `permissions: {}` with per-job `id-token: write` + `contents: read`, tag glob `'**[0-9]+.[0-9]+.[0-9]+*'`, token-less OIDC (no secret). Current crate/gem version baseline: **`0.3.0`**.

---

## 1. Architecture & directory tree

Two constraints collide and must be reconciled:

1. **rb-sys / rake-compiler hard-expect `ext/<gem>/extconf.rb`** and `create_rust_makefile("<gem>/<gem>")`. Fighting this is not worth it.
2. **sasso's `wasm/`-style convention**: a top-level dir, excluded from the core workspace, with its OWN empty `[workspace]` table so cargo's upward manifest walk stops there (worktree-safe).

**Reconciliation:** the gem root is the new top-level `ruby/` dir, but the *cdylib crate* sits one level deeper at `ruby/ext/sasso/` (rb-sys's required path). The empty-`[workspace]`-table + workspace-exclude convention is applied to **that inner crate** (`ruby/ext/sasso/Cargo.toml`), not to `ruby/` itself. This is the only deviation from the literal `wasm/` shape, and it's forced by rb-sys.

```
rust-sass/
├── Cargo.toml                       # EDIT: exclude += "ruby/ext/sasso"; pkg exclude += "/ruby"
├── src/ …                           # core crate, UNTOUCHED (keeps unsafe_code="deny")
├── wasm/ …                          # existing npm wrapper (the pattern we mirror)
└── ruby/                            # NEW — gem root
    ├── .gitignore                   # target/  pkg/  tmp/  *.bundle  *.so  Gemfile.lock
    ├── Gemfile                      # gemspec + dev gems
    ├── Rakefile                     # RbSys::ExtensionTask + Minitest::TestTask
    ├── sasso.gemspec                # version from lib/sasso/version.rb
    ├── README.md
    ├── LICENSE-APACHE  LICENSE-MIT  # copied at package time (see step S2)
    ├── lib/
    │   └── sasso/
    │       ├── version.rb           # Sasso::VERSION  (single source of truth)
    │   └── sasso.rb                 # require shim + pure-Ruby kwargs API
    ├── sig/
    │   └── sasso.rbs                # RBS type signatures
    ├── test/
    │   ├── test_helper.rb
    │   ├── compile_test.rb          # unit tests
    │   └── parity_test.rb           # byte-parity vs the CLI binary
    └── ext/
        └── sasso/                   # THE cdylib crate (rb-sys's required path)
            ├── Cargo.toml           # empty [workspace] + cdylib + magnus + path dep
            ├── Cargo.lock           # committed (reproducible source builds)
            ├── extconf.rb           # rb_sys/mkmf -> create_rust_makefile("sasso/sasso")
            ├── build.rs             # rb-sys-env (links Ruby)
            └── src/
                └── lib.rs           # #[magnus::init] -> Sasso::Native._compile
```

**Path-dep depth (the #1 build-failure trap):** the crate is at `ruby/ext/sasso/`, so the relative path to the repo root is `../../..` (`ext/sasso → ext → ruby → root`). **Verify with `cargo metadata` before committing** (gate G1).

**Why both the exclude AND the empty `[workspace]`:** without `"ruby/ext/sasso"` in the root exclude, the core crate's workspace would try to absorb the cdylib (and its magnus deps), polluting the core's lint posture. Without the empty `[workspace]` table in the inner crate, cargo's upward walk from a nested `.claude/worktrees/` checkout escapes into the outer repo whose *relative* exclude can't match the worktree path — the exact bug `wasm/Cargo.toml`'s comment documents. Both are mandatory.

**Crate name decision:** name the cdylib crate **`sasso-ruby`** (package name), but keep `[lib] name = "sasso"` so rake-compiler produces `libsasso.{so,bundle}` and `require "sasso/sasso"` works. Naming the *package* `sasso-ruby` (vs the path-dep `sasso`) avoids the same-name package collision the research flagged, while the `[lib] name` (what's coupled to `create_rust_makefile` + `ExtensionTask`) stays `sasso`.

---

## 2. Concrete skeletons (copy-pasteable)

### 2a. Root `Cargo.toml` — two-line edit

```toml
# [workspace] section:
[workspace]
exclude = ["wasm", "ruby/ext/sasso"]   # was: ["wasm"]

# [package] section:
exclude = ["/bench", "/spec", "/docs", "/.github", "/wasm", "/ruby"]
```

### 2b. `ruby/ext/sasso/Cargo.toml`

```toml
# The Ruby native-extension wrapper: a cdylib around `sasso::compile`, shipped
# inside the `sasso` gem (NOT to crates.io). Kept OUT of the core workspace (see
# ../../../Cargo.toml `[workspace] exclude = ["ruby/ext/sasso"]`) so the core
# crate keeps `unsafe_code = "deny"`; magnus/rb-sys generate code that may use
# unsafe internally, so this crate does NOT set the forbid/deny lint.
#
# Self-contained workspace root: stops cargo's upward manifest walk here, so the
# crate resolves identically from the main checkout AND from git worktrees
# nested under .claude/worktrees/ (where the walk would otherwise escape into
# the outer repo's workspace, whose relative exclude can't match). Mirrors
# wasm/Cargo.toml.
[workspace]

[package]
name = "sasso-ruby"           # package name (avoids colliding with the `sasso` path dep)
version = "0.3.0"             # cosmetic; the GEM version is lib/sasso/version.rb
edition = "2021"
rust-version = "1.74"
license = "MIT OR Apache-2.0"
publish = false

[lib]
# MUST equal the ExtensionTask name and create_rust_makefile("sasso/sasso") arg:
# rake-compiler looks for lib<name>.{so,bundle} and renames it. Keep it `sasso`.
name = "sasso"
crate-type = ["cdylib"]

[dependencies]
# Build-time only — NOT runtime gem deps. Preserves sasso's zero-runtime-dep promise.
magnus = { version = "0.8", features = ["rb-sys"] }   # 0.8.2 latest; pulls rb-sys ~0.9.124
sasso  = { path = "../../.." }                          # ext/sasso -> ext -> ruby -> repo root

[build-dependencies]
rb-sys-env = "0.2"

[profile.release]
lto = "thin"
codegen-units = 1
strip = true
# NOTE: do NOT add panic = "abort" here. magnus relies on unwinding to catch
# Rust panics and convert them to a Ruby `fatal` exception; abort would kill the
# Ruby VM outright. (The wasm crate uses panic=abort because it owns its process;
# the gem shares the process with Ruby, so it must NOT.)
```

> **GVL note (deferred from the skeleton):** the testing-integration research proposed `lucchetto = "0.2"` `#[without_gvl]` to release the GVL during compile. That is a real win for big stylesheets but adds a dependency and a correctness constraint (no Ruby VALUE may be touched inside the nogvl fn). **It is NOT in v1** — see §6 R-3 and step S7. v1 holds the GVL (simplest, correct).

### 2c. `ruby/ext/sasso/build.rs`

```rust
fn main() {
    // Activates rb-sys's link flags for the host Ruby. Required for magnus 0.8.
    let _ = rb_sys_env::activate().expect("rb-sys-env activate failed");
}
```

### 2d. `ruby/ext/sasso/src/lib.rs`

```rust
//! Magnus binding: exposes the flat native ABI `Sasso::Native._compile(...)`,
//! delegating to `sasso::compile`. Ergonomic kwargs + validation live in
//! ruby/lib/sasso.rb. The core crate denies unsafe; this thin FFI layer is the
//! unsafe boundary (magnus hides it — we write zero explicit `unsafe`).
//!
//! Importer policy (v1): a built-in Rust `FsImporter` driven by `load_paths`.
//! A Ruby-callback importer is deferred (GC-pinning + GVL re-entrancy hazards).

use magnus::{function, prelude::*, Error, RArray, Ruby};
use std::path::PathBuf;

/// Native ABI. Args are pre-validated/normalized by the Ruby wrapper, so this
/// stays a flat positional function. Never panics across FFI — always Result.
fn native_compile(
    ruby: &Ruby,
    source: String,
    style: String,
    syntax: String,
    load_paths: RArray,
    url: Option<String>,
    unicode: bool,
) -> Result<String, Error> {
    let mut opts = sasso::Options::default()
        .with_style(match style.as_str() {
            "compressed" => sasso::OutputStyle::Compressed,
            _ => sasso::OutputStyle::Expanded,
        })
        .with_syntax(match syntax.as_str() {
            "sass" => sasso::Syntax::Sass,
            "css" => sasso::Syntax::Css,
            _ => sasso::Syntax::Scss,
        })
        .with_unicode(unicode);

    // `url` is load-bearing: it ENABLES the byte-exact dart diagnostic block.
    // Bind it for the whole `compile` call (Options borrows &str).
    if let Some(ref u) = url {
        opts = opts.with_url(u);
    }

    // Build the filesystem importer from load_paths. Bind it before `compile`
    // so the &dyn Importer borrow outlives the call.
    let paths: Vec<PathBuf> = load_paths
        .into_iter()
        .filter_map(|v| String::try_convert(v).ok())
        .map(PathBuf::from)
        .collect();
    let importer = sasso::FsImporter::new(paths.clone());
    if !paths.is_empty() {
        opts = opts.with_importer(&importer);
    }

    sasso::compile(&source, &opts).map_err(|e| {
        // Raise a rescuable Sasso::CompileError carrying the FULL rendered
        // diagnostic (what the CLI prints). NEVER panic.
        let klass = ruby
            .class_object()
            .const_get::<_, magnus::ExceptionClass>("Sasso::CompileError")
            .unwrap_or_else(|_| ruby.exception_runtime_error());
        Error::new(klass, e.to_string())
    })
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Sasso")?;
    // Error hierarchy is also (re)opened in lib/sasso.rb; defining it here too is
    // idempotent and lets the native fn raise it even if required out of order.
    let base = module.define_error("Error", ruby.exception_standard_error())?;
    module.define_error("CompileError", base)?;
    // Flat native ABI under Sasso::Native; ergonomic API is pure Ruby.
    let native = module.define_module("Native")?;
    native.define_module_function("_compile", function!(native_compile, 6))?;
    Ok(())
}
```

> **magnus 0.8 API caveat (§6 R-6):** if `const_get::<_, ExceptionClass>` or `define_error` don't compile against the exact published 0.8.x, fall back to `Error::new(ruby.exception_runtime_error(), e.to_string())` (no custom class) and define `Sasso::CompileError` purely in Ruby. This is a build-time gate, not a design risk.

### 2e. `ruby/ext/sasso/extconf.rb`

```ruby
# frozen_string_literal: true
require "mkmf"
require "rb_sys/mkmf"

# Arg MUST match [lib] name and ExtensionTask name. The "sasso/sasso" nesting
# places the artifact at lib/sasso/sasso.{so,bundle} so `require "sasso/sasso"`
# resolves. Honor RB_SYS_CARGO_PROFILE so cross-gem builds use release.
create_rust_makefile("sasso/sasso") do |r|
  r.profile = ENV.fetch("RB_SYS_CARGO_PROFILE", "release").to_sym
end
```

### 2f. `ruby/lib/sasso/version.rb`

```ruby
# frozen_string_literal: true
module Sasso
  # MUST equal the `version` in the root Cargo.toml. CI asserts equality (G5)
  # and the release workflow asserts it equals the pushed tag (S9).
  VERSION = "0.3.0"
end
```

### 2g. `ruby/lib/sasso.rb`

```ruby
# frozen_string_literal: true
require_relative "sasso/version"

# Load the compiled extension. Precompiled (fat) gems place a .so per Ruby minor
# under lib/sasso/<major.minor>/; the source build places a flat lib/sasso/sasso.
begin
  ruby_ver = "#{RbConfig::CONFIG["MAJOR"]}.#{RbConfig::CONFIG["MINOR"]}"
  require_relative "sasso/#{ruby_ver}/sasso"
rescue LoadError
  require_relative "sasso/sasso"
end

module Sasso
  # Defined in Rust too (idempotent); kept here as the canonical declaration.
  class Error        < StandardError; end
  class CompileError < Error; end

  STYLES   = %i[expanded compressed].freeze
  SYNTAXES = %i[scss sass css].freeze

  module_function

  # Compile a SCSS/Sass source String to a CSS String.
  #
  #   style:       :expanded (default) | :compressed
  #   syntax:      :scss (default) | :sass | :css
  #   indented:    true => shorthand for syntax: :sass
  #   load_paths:  dirs searched for @use/@import (built-in Rust FsImporter)
  #   url:         filename shown in diagnostics; ENABLES dart-exact error blocks
  #   alert_ascii: true => ASCII diagnostics (maps to Rust with_unicode(false))
  #
  # Raises Sasso::CompileError on a compile failure; ArgumentError on bad opts.
  def compile_string(source, style: :expanded, syntax: :scss, indented: false,
                     load_paths: [], url: nil, alert_ascii: false)
    syntax = :sass if indented
    validate!(style, STYLES, :style)
    validate!(syntax, SYNTAXES, :syntax)
    paths = Array(load_paths).map(&:to_s)
    Sasso::Native._compile(String(source), style.to_s, syntax.to_s,
                           paths, url&.to_s, !alert_ascii)
  end

  # Compile a file at `path` (syntax inferred from extension unless overridden).
  # Defaults url: to the path so diagnostics get the dart-exact block for free.
  def compile(path, **opts)
    src      = File.read(path)
    inferred = case File.extname(path)
               when ".sass" then :sass
               when ".css"  then :css
               else :scss
               end
    compile_string(src, syntax: inferred, url: path.to_s, **opts)
  end

  def validate!(value, allowed, name)
    return if allowed.include?(value)
    raise ArgumentError,
          "invalid #{name}: #{value.inspect} (expected one of #{allowed.inspect})"
  end
  private_class_method :validate!
end
```

### 2h. `ruby/sasso.gemspec`

```ruby
# frozen_string_literal: true
require_relative "lib/sasso/version"

Gem::Specification.new do |spec|
  spec.name        = "sasso"
  spec.version     = Sasso::VERSION          # single source of truth
  spec.authors     = ["momiji-rs"]
  spec.summary     = "Pure-Rust SCSS to CSS compiler (a dart-sass alternative), in-process via a native extension."
  spec.description = "Embeddable, zero-runtime-dependency SCSS compiler aiming at byte-for-byte dart-sass parity."
  spec.homepage    = "https://github.com/momiji-rs/sasso"
  spec.license     = "MIT OR Apache-2.0"
  spec.required_ruby_version     = ">= 3.1.0"   # matches the cross-compile minor floor
  spec.required_rubygems_version = ">= 3.3.22"  # clean precompiled-platform resolution

  spec.metadata = {
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir[
    "lib/**/*.rb",
    "ext/**/*.{rs,rb,toml,lock}",
    "ext/**/build.rs",
    "sig/**/*.rbs",
    "LICENSE-*", "README.md",
  ]
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/sasso/extconf.rb"]   # source-compile fallback

  # rb_sys is the ONLY runtime dep, and ONLY exercised on the compile-from-source
  # path. Precompiled platform gems ship the prebuilt binary and skip it.
  # magnus / rake-compiler are build/dev only -> zero-runtime-dep preserved.
  spec.add_dependency "rb_sys", "~> 0.9.111"

  spec.add_development_dependency "rake",           "~> 13.0"
  spec.add_development_dependency "rake-compiler",  "~> 1.2"
  spec.add_development_dependency "minitest",       "~> 5.0"
end
```

### 2i. `ruby/Rakefile`

```ruby
# frozen_string_literal: true
require "bundler/gem_tasks"
require "minitest/test_task"
require "rb_sys/extensiontask"

GEMSPEC = Gem::Specification.load("sasso.gemspec")

# First arg MUST equal the crate [lib] name = "sasso".
RbSys::ExtensionTask.new("sasso", GEMSPEC) do |ext|
  ext.lib_dir       = "lib/sasso"
  ext.cross_compile = true
  ext.cross_platform = %w[
    x86_64-linux aarch64-linux x86_64-linux-musl aarch64-linux-musl
    x86_64-darwin arm64-darwin x64-mingw-ucrt
  ]
end

Minitest::TestTask.create

task default: %i[compile test]
```

### 2j. `ruby/Gemfile`

```ruby
# frozen_string_literal: true
source "https://rubygems.org"
gemspec
gem "rb_sys", "~> 0.9.111"   # provides RbSys::ExtensionTask at dev/build time
```

### 2k. `ruby/sig/sasso.rbs`

```rbs
module Sasso
  VERSION: String
  STYLES: Array[Symbol]
  SYNTAXES: Array[Symbol]

  class Error < StandardError end
  class CompileError < Error end

  def self.compile_string: (String source, ?style: Symbol, ?syntax: Symbol,
                            ?indented: bool, ?load_paths: Array[String | _ToS],
                            ?url: String?, ?alert_ascii: bool) -> String
  def self.compile: (String | _ToS path, **untyped) -> String
end
```

### 2l. `ruby/test/parity_test.rb` (the parity gate)

```ruby
# frozen_string_literal: true
require_relative "test_helper"
require "open3"

# Proves the in-process path byte-matches the already-100%-conformant CLI.
class ParityTest < Minitest::Test
  CLI = File.expand_path("../../target/release/sasso", __dir__)

  def cli(scss, *args)
    out, _err, st = Open3.capture3(CLI, "--stdin", *args, stdin_data: scss)
    st.success? ? out : nil
  end

  CASES = [
    "a{b:1px + 2px}",
    ".x{&:hover{c:red}}",
    "$v:1;d{e:$v}",
    "$c:#333;a{color:$c}",
  ].freeze

  CASES.each_with_index do |scss, i|
    define_method("test_parity_expanded_#{i}") do
      want = cli(scss)
      skip "CLI not built (run `cargo build --release`)" unless want
      assert_equal want, Sasso.compile_string(scss)
    end
    define_method("test_parity_compressed_#{i}") do
      want = cli(scss, "--style", "compressed")
      skip "CLI not built" unless want
      assert_equal want, Sasso.compile_string(scss, style: :compressed)
    end
  end
end
```

`test/test_helper.rb`:

```ruby
# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "sasso"
```

### 2m. `.github/workflows/release-gem.yml`

```yaml
name: Publish gem (RubyGems)

# Cross-compiles precompiled native gems for every supported Ruby platform
# (oxidize-rb/actions/cross-gem), builds the source-compile fallback gem, then
# pushes them all via RubyGems Trusted Publishing (OIDC) on a version tag — NO
# RUBYGEMS API KEY secret, mirroring release-wasm.yml / release-crate.yml.
#
# ONE-TIME setup on rubygems.org for gem `sasso` BEFORE the first tag push:
#   Profile -> Trusted Publishers -> Create a pending publisher (the gem does
#   not exist yet, so it must be a *pending* publisher under your profile):
#     RubyGem:     sasso
#     Owner:       momiji-rs
#     Repository:  sasso
#     Workflow:    release-gem.yml
#     Environment: release
# After the first publish, manage it on the gem page's Trusted Publishers tab.

on:
  push:
    tags:
      - '**[0-9]+.[0-9]+.[0-9]+*'

permissions: {}

jobs:
  cross-gems:
    name: cross gem (${{ matrix.platform }})
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        platform:
          - x86_64-linux
          - aarch64-linux
          - x86_64-linux-musl
          - aarch64-linux-musl
          - x86_64-darwin
          - arm64-darwin
          - x64-mingw-ucrt
    steps:
      - uses: actions/checkout@v6
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
      - uses: oxidize-rb/actions/cross-gem@v1   # NOT the archived cross-gem-action@v7
        id: cross-gem
        with:
          platform: ${{ matrix.platform }}
          ruby-versions: "3.1, 3.2, 3.3, 3.4"
          working-directory: ruby
      - uses: actions/upload-artifact@v4
        with:
          name: cross-gem-${{ matrix.platform }}
          path: ruby/pkg/*-${{ matrix.platform }}.gem
          if-no-files-found: error

  publish:
    name: push to RubyGems
    needs: cross-gems
    runs-on: ubuntu-latest
    environment: release
    permissions:
      id-token: write   # OIDC: mint short-lived RubyGems token (no secret)
      contents: read
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
      - uses: actions/download-artifact@v4
        with:
          path: ruby/pkg
          pattern: cross-gem-*
          merge-multiple: true

      - name: build source-compile fallback gem
        working-directory: ruby
        run: gem build sasso.gemspec -o "pkg/sasso-$(ruby -r./lib/sasso/version -e 'print Sasso::VERSION').gem"

      - name: verify gem version == tag
        working-directory: ruby
        run: |
          gem_v=$(ruby -r./lib/sasso/version -e 'print Sasso::VERSION')
          if [ "v${gem_v}" != "${GITHUB_REF_NAME}" ]; then
            echo "version.rb (${gem_v}) != tag (${GITHUB_REF_NAME})"; exit 1
          fi

      - name: smoke-install x86_64-linux precompiled gem
        working-directory: ruby
        run: |
          gem install --local pkg/sasso-*-x86_64-linux.gem
          ruby -rsasso -e 'puts Sasso.compile_string("a{b:1px}")' | grep -q 'b: 1px'

      # OIDC token exchange (RubyGems Trusted Publishing) — no GEM_HOST_API_KEY.
      - uses: rubygems/configure-rubygems-credentials@v1.0.0

      - name: gem push (platform gems first, source fallback last)
        working-directory: ruby/pkg
        run: |
          shopt -s nullglob
          for g in sasso-*-*.gem; do gem push "$g"; done   # precompiled platforms
          for g in sasso-*.gem;   do gem push "$g" || true; done  # source fallback
```

> Pin `oxidize-rb/actions/cross-gem` and `configure-rubygems-credentials` to the tags shown; the standalone `oxidize-rb/cross-gem-action@v7` is **archived** — do not use it.

---

## 3. The Ruby API (v1 surface)

Mirror **sass-embedded** (the living, recommended gem; `sassc` is EOL — do NOT mimic `SassC::Engine#render`):

| Surface | v1 | Maps to |
|---|---|---|
| `Sasso.compile_string(source, **opts) -> String` | ✅ | `sasso::compile(&source, &opts)` |
| `Sasso.compile(path, **opts) -> String` | ✅ | reads file, infers syntax, sets `url:` |
| `style:` `:expanded`(default)/`:compressed` | ✅ | `with_style` |
| `syntax:` `:scss`(default)/`:sass`/`:css` | ✅ | `with_syntax` |
| `indented: true` (alias for `syntax: :sass`) | ✅ | convenience |
| `load_paths: [String\|Pathname]` | ✅ | `FsImporter::new` → `with_importer` |
| `url:` (enables byte-exact diagnostics) | ✅ | `with_url` |
| `alert_ascii: true` (inverts unicode) | ✅ | `with_unicode(false)` |
| `Sasso::CompileError < Sasso::Error < StandardError`, `.message` = full rendered diagnostic | ✅ | `e.to_string()` |
| Unknown `style:`/`syntax:` symbol | ✅ | raises `ArgumentError` (matches sass-embedded) |
| **Deferred → v2:** Ruby-callback importer (`canonicalize`/`load` protocol or a `Proc`) | ❌ | `with_importer` + a Rust `Importer` bridging into Ruby (GC-pin + GVL — §6 R-2) |
| **Deferred → v2:** `Sasso::CompileResult` struct (`.css`/`.source_map`/`.loaded_urls`) | ❌ | core `compile` returns only `String`; switch in a future MINOR bump when source maps land |
| **Deferred → v2:** GVL release during compile | ❌ | §6 R-3 |

Returning a bare `String` (not a `CompileResult`) is a deliberate, documented v1 divergence from sass-embedded — the core `compile` yields only a `String`. Don't promise a struct now.

---

## 4. CI / precompiled-gem matrix

**Test job** — add to the existing `.github/workflows/ci.yml` (new job, mirroring its style):

```yaml
  ruby:
    name: ruby gem · compile + test
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
        ruby: ["3.1", "3.2", "3.3", "3.4"]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v6
      - uses: oxidize-rb/actions/setup-ruby-and-rust@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          rustup-toolchain: stable
          bundler-cache: true
          cargo-cache: true
          working-directory: ruby
      - name: build CLI (for the parity gate)
        run: cargo build --release
      - name: compile + test
        working-directory: ruby
        run: bundle exec rake
```

**Precompiled matrix** (in `release-gem.yml`, §2m): `x86_64-linux`, `aarch64-linux`, `x86_64-linux-musl`, `aarch64-linux-musl`, `x86_64-darwin`, `arm64-darwin`, `x64-mingw-ucrt` — the same target spirit as cargo-dist's list, minus 32-bit `arm-linux` and legacy `x64-mingw32` (Ruby 3.1+ uses UCRT). Each platform `.gem` is a **fat gem** bundling one `.so` per Ruby minor (3.1–3.4) — the rb-sys stable-ABI single-binary mode is opt-in and still maturing, so ship per-minor fat gems for the first release (revisit as a size optimization later).

**Source fallback (mandatory):** the source gem is built and pushed **last** so `gem install sasso` works on un-precompiled platforms (FreeBSD, riscv, Ruby HEAD) by compiling via `extconf.rb`.

**Version sync:** `lib/sasso/version.rb` is the single source of truth. CI guard (gate **G5**) asserts it equals the root `Cargo.toml` version; the release workflow asserts it equals the pushed tag.

---

## 5. Sequenced steps (atomic, gate-able)

Each step is one reviewable commit (or a tight cluster). Gate = the check that must pass before moving on.

| Step | Work | Gate |
|---|---|---|
| **S1. Wire the crate in** | Edit root `Cargo.toml` (workspace exclude + package exclude). Create `ruby/ext/sasso/{Cargo.toml,build.rs,src/lib.rs (stub `_compile` returning the input),extconf.rb}`. | **G1:** `cargo metadata --manifest-path ruby/ext/sasso/Cargo.toml --format-version 1` resolves the `sasso` path dep (proves `../../..` depth). `cargo build --release --manifest-path ruby/ext/sasso/Cargo.toml` produces `libsasso.{dylib,so}`. `cargo build --release` at root still works AND does NOT pull magnus (core workspace untouched). Verify a nested worktree build too (the empty `[workspace]` test). |
| **S2. Full Rust binding** | Real `native_compile` (§2d) mapping all options + `FsImporter` + error→`CompileError`. Add `ruby/{Gemfile,Rakefile,sasso.gemspec}`, `lib/sasso.rb`, `lib/sasso/version.rb`, license symlinks/copies. | **G2:** `cd ruby && bundle install && bundle exec rake compile` produces `lib/sasso/sasso.{bundle,so}`. |
| **S3. `Sasso.compile` works locally** | `lib/sasso.rb` kwargs wrapper + validation. | **G3:** `ruby -Ilib -rsasso -e 'puts Sasso.compile_string("$c:#333;a{color:$c}")'` emits expanded CSS; `style: :compressed` minifies; a bad symbol raises `ArgumentError`; a syntax error raises `Sasso::CompileError` whose `.message` is the full dart-style block (pass a `url:`). |
| **S4. Test suite + parity gate** | `test/{test_helper,compile_test,parity_test}.rb`, `sig/sasso.rbs`, `ruby/README.md`. | **G4:** `cargo build --release` then `cd ruby && bundle exec rake` (compile+test) green; parity tests byte-match the CLI for expanded + compressed. |
| **S5. Version-sync guard** | A rake task or CI step parsing root `Cargo.toml` version and asserting `== Sasso::VERSION`. | **G5:** task fails on a deliberately mismatched version, passes when aligned. |
| **S6. CI test job** | Add the `ruby` matrix job to `ci.yml` (§4). | **G6:** CI green on ubuntu+macos × Ruby 3.1–3.4. |
| **S7. (Optional) GVL release** | Add `lucchetto`, split into a GVL-held marshaling fn + a `#[without_gvl]` worker taking only owned `String`/`bool`. | **G7:** all S4 tests still pass; a Ruby-thread-progress micro-test shows another thread runs during a large compile; bench shows no regression on small inputs (gate behind a size threshold if needed). **Skip for v1 if time-boxed.** |
| **S8. Precompiled gems in CI (dry run)** | Add `release-gem.yml` (§2m) but trigger on a throwaway branch/`workflow_dispatch` first. | **G8:** all 7 platform gems build; `actions/upload-artifact` succeeds; the `x86_64-linux` smoke-install + `Sasso.compile_string` step passes. No push yet. |
| **S9. Trusted-publishing release** | One-time: register the **pending** Trusted Publisher on rubygems.org (gem `sasso`, owner `momiji-rs`, repo `sasso`, workflow `release-gem.yml`, env `release`). Enable the `release` environment in repo settings (mirror `release-crate.yml`). Switch the trigger to the tag glob. | **G9:** push `vX.Y.Z` → release-gem.yml fans out alongside release-crate/release-wasm/cargo-dist; version-vs-tag guard passes; OIDC exchange succeeds (no secret); all platform gems + source gem land on rubygems.org; `gem install sasso` on Apple Silicon installs the precompiled `arm64-darwin` gem (no Rust toolchain invoked). |

---

## 6. Risks & open decisions (verify before committing)

- **R-1 — Global allocator (RESOLVED by repo inspection):** confirmed `src/lib.rs` installs **no** `#[global_allocator]`; only `src/main.rs:30` does. The gem MUST NOT add one — replacing Ruby's malloc (which GC-managed objects use) is UB-adjacent and would corrupt the VM. The arena is inert under the system allocator (one redundant clone). No action needed beyond *not* adding `ScopedAlloc`.
- **R-2 — Importer bridge (DEFERRED, by design):** `with_importer(&'a dyn Importer)` is a borrowed trait object. A Ruby-callback importer is feasible (a `Proc`/object responding to sass-embedded's `canonicalize`/`load`) but carries two hard hazards: (a) the Ruby callable must be **GC-pinned for the whole compile** (magnus `BoxValue`/gc-register; a bare `Value` collected mid-run is UB); (b) calling Ruby from Rust **requires holding the GVL**, so a callback importer forces the whole compile single-threaded under the GVL (conflicts with R-3). v1 ships the zero-risk Rust `FsImporter` driven by `load_paths:`, which covers the 95% Rails case. The trait + `with_importer` make v2 a clean addition.
- **R-3 — GVL release (DEFERRED):** `compile()` is pure-CPU and touches no Ruby VALUEs, so releasing the GVL is safe and helps concurrency on large inputs — **but** the nogvl worker must take only `GvlSafe` owned types (no `RString`/`RArray` may cross in), all marshaling/raising must stay in the outer GVL-held fn, and small inputs see net-negative overhead (gate behind a size threshold). Not worth the added dep/complexity for v1; revisit in S7/v2.
- **R-4 — Panic across FFI (MITIGATED):** magnus 0.8 catches Rust panics and converts them to an **uncatchable Ruby `fatal`** (tears down the VM, can't be `rescue`d). Mitigation: the binding returns `Result<String, magnus::Error>` and raises a rescuable `Sasso::CompileError` for all `sasso::Error`s; reserve `panic!`/`unwrap` for genuine bugs only. **Verify:** do NOT set `panic = "abort"` in the ext crate's release profile (the skeleton omits it deliberately) — abort would defeat magnus's catch.
- **R-5 — Path-dep depth + worktree walk (VERIFY at G1):** `../../..` is correct for `ruby/ext/sasso/`. Confirm with `cargo metadata`, and confirm both the root `[workspace] exclude` entry AND the inner empty `[workspace]` table are present (test a nested-worktree build). Getting either wrong is the most common failure.
- **R-6 — magnus 0.8 API churn (VERIFY at S2/G2):** `define_error`, `define_module_function`, `const_get::<_, ExceptionClass>` signatures shifted across 0.6→0.7→0.8. Pin `magnus = "0.8"`; if any don't compile against the exact published 0.8.x, fall back to `Error::new(ruby.exception_runtime_error(), msg)` + a pure-Ruby `Sasso::CompileError`. Low risk, build-time only.
- **R-7 — Trusted Publishing one-time setup (BLOCKS S9):** tokenless OIDC `gem push` 403s until a publisher is registered on rubygems.org. For a never-published gem, use the **pending publisher** flow under your profile (the gem-page tab only appears once the gem exists). Same caveat the npm OIDC setup hit.
- **R-8 — Cargo.lock policy (DECIDE at S2):** for a gem shipping a source-compile fallback, the convention is to **commit `ruby/ext/sasso/Cargo.lock`** and include it in `spec.files` for reproducible source builds. (The core crate is a library and doesn't commit a lock; the cdylib is application-like — commit it.)
- **R-9 — Two result copies (ACCEPTED):** `compile` deep-clones out of the arena (system heap), then magnus copies into a Ruby String — two copies. Fine for correctness; just expect the extra alloc in profiles. No action.

---

## 7. Effort estimate

| Step | Estimate | Notes |
|---|---|---|
| S1 wire crate in | **2–3 h** | Mostly the `cargo metadata`/worktree verification. |
| S2 full Rust binding | **3–4 h** | Plus magnus 0.8 API confirmation (R-6) — budget +1 h if `define_error` needs the fallback. |
| S3 Ruby wrapper | **1–2 h** | |
| S4 tests + parity + RBS + README | **3–4 h** | |
| S5 version guard | **0.5 h** | |
| S6 CI test job | **1–2 h** | Iterating on the matrix in CI. |
| S7 GVL release (optional) | **2–3 h** | Only if doing it in v1; otherwise 0. |
| S8 precompiled gems (dry run) | **3–5 h** | cross-gem-action iteration is the slow part (rb-sys-dock containers, per-platform debugging). |
| S9 trusted-publishing release | **1–2 h** + one-time rubygems.org setup | OIDC config is clicks, not code. |
| **Total (v1, S7 deferred)** | **≈ 2–3 focused days** | S8 is the long pole. |

**Critical path / recommended order:** S1 → S2 → S3 (this is "`Sasso.compile` works locally", ~1 day) → S4–S6 (tested + CI, ~0.5–1 day) → S8 → S9 (precompiled + release, ~1 day). Defer S7 (GVL) and the v2 importer/`CompileResult` until after the first published gem.

**Relevant files:** plan targets `Cargo.toml` (2-line edit), the new `ruby/` tree, `.github/workflows/ci.yml` (add `ruby` job), and new `.github/workflows/release-gem.yml`. Grounded against `src/lib.rs`, `src/error.rs`, `src/main.rs`, `wasm/Cargo.toml`, and `.github/workflows/release-wasm.yml`.
