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
    rev = "v0.9.0";
    hash = "sha256-SUYF4bbaYwNgoe498VoCUzuLPcjBLQXR0o0DWjjoSnI=";
  };

  # upstream の vendor/libghostty-vt/build.zig.zon.nix をここに取り込んである。
  # "${src}/..." を callPackage すると IFD になり、nix-env -qa の読み取り専用の
  # 評価ストアでは src の .drv を書けずに落ちる（NUR の評価器も IFD を通さない）。
  # version を上げるときは update.sh がこのファイルも取り直す
  zigDeps = callPackage ./build.zig.zon.nix {
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
  version = "0.9.0";
  inherit src;

  # "${src}/Cargo.lock" を cargoLock に渡すと、評価時に src を読むため IFD になる。
  # nix-env -qa（読み取り専用の評価ストア）と NUR の評価器がそこで落ちる。
  # vendor 済みの hash を置けば評価は src に触らない。更新は just fix-hashes herdr
  cargoHash = "sha256-CW/SF/cAPDv47gS5B7XbVZEE6LC9F1a2I1TLTJ4AWdw=";

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
