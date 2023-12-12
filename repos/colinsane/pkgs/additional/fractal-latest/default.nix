{ fractal-next
, fetchFromGitLab
, git
, rustPlatform
, unstableGitUpdater
}:

let
  self = fractal-next.overrideAttrs (upstream: rec {
    pname = "fractal-latest";
    version = "unstable-2023-11-24";
    src = fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "fractal";
      rev = "a9ac0d482cef3a3c84a50ca0706c2a9ab4d4f468";
      hash = "sha256-OR+SRS4xs3rLGGHhsWxTatpiN6SMGeyhhr9zO+vxz+E=";
    };

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        # hashes for git dependencies (?). when updating the package:
        # 1. reset this to {}
        # 2. build, it will fail, but warn that a hash is missing here
        # 3. add "<crate_thats_missing_hash>" = "";
        # 4. repeat until no more crates are missing hashes
        # 5. build, and nix will let you know what the actual hashes should be
        # TODO: alternative is to set `allowBuiltinFetchGit = true;`
        "mas-http-0.5.0-rc.2" = "sha256-XH+I5URcbkSY4NDwfOFhIjb+/swuGz6n9hKufziPgoY=";
        "matrix-sdk-0.6.2" = "sha256-X+4077rlaE8zjXHXPUfiYwa/+Bg0KTFrcsAg7yCz4ug=";
      };
    };

    nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      git  # only necessary when profile is development or hack
    ];

    mesonFlags = (upstream.mesonFlags or []) ++ [
      # profile: default, beta, development, hack.
      # - default causes a 2hr+ build, 98% of that being `rustc fractal` using a single core
      # - development has the same problem
      # - hack brings the build down to ~5 minutes, possibly because it doesn't pass --release to cargo
      #   - it still has rustc using ~4 cores typical
      # development and hack both require `git`
      "-Dprofile=hack"
    ];

    # codegen settings, see: <https://doc.rust-lang.org/rustc/codegen-options/index.html>
    # trying to speed up compilation. see deep dive: <https://fasterthanli.me/articles/why-is-my-rust-build-so-slow>
    # - `RUSTC_BOOTSTRAP=1` allows using nightly rustc options
    # postPatch = (upstream.postPatch or "") + ''
    #   # sed -i "s/^codegen-units = .*$/codegen-units = $NIX_BUILD_CORES/" Cargo.toml
    #   sed -i 's/^codegen-units = .*$/codegen-units = 256/' Cargo.toml
    #   sed -i 's/^lto = .*$/lto = "off"/' Cargo.toml
    #   sed -i 's/debug = true/debug = false/' Cargo.toml
    #   sed -i "s/cargo_options,/cargo_options + [ '-j$NIX_BUILD_CORES', '--verbose', '--timings' ],/" src/meson.build
    # '';
    # preConfigure = (upstream.preConfigure or "") + ''
    #   export CARGO_BUILD_JOBS=$NIX_BUILD_CORES
    #   export RUSTFLAGS="-C codegen-units=256"
    # '';

    passthru.updateScript = unstableGitUpdater {};
  });
in self // {
  meta = self.meta // {
    # ensure nix thinks the canonical position of this derivation is inside my own repo,
    # not upstream nixpkgs repo. this ensures that the updateScript can patch the version/hash
    # of the right file. meta.position gets overwritten if set in overrideAttrs, hence this
    # manual `//` hack
    position = let
      pos = builtins.unsafeGetAttrPos "updateScript" self.passthru;
    in "${pos.file}:${builtins.toString pos.line}";
  };
}
