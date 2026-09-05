{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  callPackage,
  git,
  pkg-config,
  cctools,
  xcbuild,
  zig_0_15,
  zstd,
  runCommand,
}:

let
  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    rev = "v0.8.2";
    hash = "sha256-sEGIN3dLZasaHob3EHscWBCIQHflMQVchYmzgsETDk4=";
  };

  zigDeps = callPackage "${src}/vendor/libghostty-vt/build.zig.zon.nix" {
    name = "herdr-libghostty-vt-zig-cache";
    inherit zstd;
    linkFarm =
      name: entries:
      runCommand name { } ''
        mkdir -p $out
        ${lib.concatMapStringsSep "\n" (entry: ''
          cp -rL ${entry.path} $out/${entry.name}
        '') entries}
      '';
  };
in
rustPlatform.buildRustPackage {
  pname = "herdr";
  version = "0.8.2";
  inherit src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs =
    [
      git
      pkg-config
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
      xcbuild
    ];

  env = {
    LIBGHOSTTY_VT_OPTIMIZE = "ReleaseFast";
    LIBGHOSTTY_VT_SIMD = "true";
    LIBGHOSTTY_VT_ZIG_SYSTEM_DIR = zigDeps;
    ZIG = lib.getExe zig_0_15;
  };

  preBuild = ''
    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig-global-cache"
    export ZIG_LOCAL_CACHE_DIR="$TMPDIR/zig-local-cache"
  '';

  doCheck = false;

  meta = {
    description = "A modern terminal-based Git client";
    homepage = "https://github.com/ogulcancelik/herdr";
    license = lib.licenses.mit;
    mainProgram = "herdr";
  };
}
