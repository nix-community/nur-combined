{
  description = "A pure-Rust SCSS to CSS compiler (a dart-sass alternative)";

  # One input, matching the crate's own posture: no flake-utils, no rust-overlay.
  # sasso is std-only and builds with whatever stable rustc nixpkgs ships, so
  # there is no toolchain to pin and nothing to keep two lock files honest about.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # The four systems `meta.platforms = unix` actually gets exercised on.
      # Windows is served by the cargo-dist binaries, not from here.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # The CLI as a consumer gets it: the same derivation with the test suite
      # left to `checks` below. Nothing serves these outputs from a binary cache,
      # so whoever takes sasso as a flake input builds it, and `checkPhase` is
      # most of that build: it recompiles every test target under the release
      # profile (thin LTO, one codegen unit). On a 4-core Linux/x86_64 builder
      # that was 201 s against 43 s without it. `versionCheckHook` still runs,
      # so a consumer's build still proves the binary starts and reports the
      # version it was built as.
      untested = sasso: sasso.overrideAttrs { doCheck = false; };
    in
    {
      packages = forAllSystems (pkgs: rec {
        sasso = untested (pkgs.callPackage ./nix/package.nix { });
        # The library half: the C ABI, for building against sasso rather than
        # running it. See nix/ffi.nix for why Rust callers don't want this.
        sasso-ffi = pkgs.callPackage ./nix/ffi.nix { };
        default = sasso;
      });

      # `nix flake check` builds both packages with their tests on: 14 test
      # executables (the library, the CLI binary, the 12 files under `tests/`)
      # — CI's `cargo test` minus the doctests, with the opt-in dart-sass
      # parity pass returning early for want of a network — plus the C ABI's
      # ctypes smoke test. `sasso` here is
      # `package.nix` as is, not the `untested` one `packages` exports.
      checks = forAllSystems (
        pkgs:
        let
          sasso = pkgs.callPackage ./nix/package.nix { };
        in
        {
          inherit sasso;
          sasso-ffi = pkgs.callPackage ./nix/ffi.nix { };

          # The acceptance criteria from issue #82, as a check that cannot rot:
          # `--version` agrees with the tree, and the flag set a real build
          # passes produces the bytes dart-sass produces.
          #
          # dart-sass is the oracle rather than a checked-in expected file, and
          # it costs nothing to keep honest: this flake's `flake.lock` pins the
          # nixpkgs that provides it, so no channel bump can turn this red
          # behind our back — only a deliberate lock update can, which is
          # exactly when we want to hear about a divergence.
          dart-compat =
            pkgs.runCommand "sasso-dart-compat"
              {
                nativeBuildInputs = [
                  sasso
                  pkgs.dart-sass
                ];
              }
              ''
                cat > in.scss <<'EOF'
                @use "sass:color";
                $brand: #336699;
                .button {
                  padding: 4px * 2;
                  color: $brand;
                  &:hover { color: color.adjust($brand, $lightness: -10%); }
                }
                EOF

                sasso --no-error-css --stop-on-error --no-color --quiet --quiet-deps \
                  --style=compressed --no-source-map in.scss:out.css
                sass --style=compressed --no-source-map in.scss:want.css
                diff -u want.css out.css

                echo "sasso ${sasso.version} == dart-sass $(sass --version): $(cat out.css)"
                test "$(sasso --version)" = "sasso ${sasso.version}"

                touch $out
              '';
        }
      );

      # For NixOS/nix-darwin configurations that want sasso before it lands in
      # their nixpkgs channel: add this overlay and `pkgs.sasso` resolves here.
      overlays.default = final: _prev: {
        sasso = untested (final.callPackage ./nix/package.nix { });
        sasso-ffi = final.callPackage ./nix/ffi.nix { };
      };

      # `nix develop` — the toolchain CI uses, including a dart-sass to compare
      # against, so the opt-in parity suite works offline:
      #   SASSO_PARITY=1 cargo test --test parity
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            cargo
            rustc
            clippy
            rustfmt
            rust-analyzer
            dart-sass # the parity reference (`$SASS_BIN`)
            nodejs # wasm/napi package tests
            binaryen # wasm-opt, for the asyncify engine
            python3 # spec/check_baseline.py, ffi/examples/*.py
          ];

          env.SASS_BIN = "${pkgs.dart-sass}/bin/sass";
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
