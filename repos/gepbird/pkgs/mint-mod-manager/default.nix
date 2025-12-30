{
  pkgs,
  lib,
  fetchFromGitHub,
  pkgsCross,
  makeRustPlatform,
  pkg-config,
  makeWrapper,
  gtk3,
  libGL,
  openssl,
  atk,
  libxkbcommon,
  wayland,
}:

let
  rust-overlay = import ./rust-overlay (
    pkgs
    // {
      inherit (rust-overlay) rust-bin;
    }
  ) { };

  rustToolchain = rust-overlay.rust-bin.selectLatestNightlyWith (
    toolchain:
    toolchain.minimal.override {
      targets = [ "x86_64-pc-windows-gnu" ];
    }
  );
  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };

  mingwPkgs = pkgsCross.mingwW64;
  mingwCompiler = mingwPkgs.buildPackages.gcc;
in
rustPlatform.buildRustPackage rec {
  pname = "mint-mod-manager";
  version = "0.2.10-unstable-2025-12-16";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "57aa964e7789f132481813a8f4b5781f924eccd1";
    hash = "sha256-gpOakUrcR2ByFFiiiYklO1rXKghaIIerxUR8rc4T5BQ=";
    deepClone = true;
    postFetch = ''
      echo -n $(git -C $out describe) > $out/GIT_VERSION
      rm -rf $out/.git
    '';
  };

  cargoHash = "sha256-5EYSiUTa50gMu2YHx6COVJU+8IFuvc5td/9TzygpeaY=";

  env = {
    # Necessary for cross compiled build scripts, otherwise it will build as ELF format
    # https://docs.rs/cc/latest/cc/#external-configuration-via-environment-variables
    CC_x86_64_pc_windows_gnu = "${mingwCompiler}/bin/${mingwCompiler.targetPrefix}cc";

    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS = "-L ${mingwPkgs.windows.pthreads}/lib";
    BUILT_OVERRIDE_mint_lib_GIT_VERSION = "unstable";
  };

  # workaround for https://github.com/NixOS/nixpkgs/pull/435278#issuecomment-3572538333
  preConfigure = ''
    unset RUSTFLAGS
  '';

  nativeBuildInputs = [
    mingwCompiler
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    gtk3
    libGL
    openssl
    atk
    libxkbcommon
    wayland
  ];

  postInstall = ''
    wrapProgram $out/bin/mint \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Deep Rock Galactic mod loader and integration";
    longDescription = ''
      Mint is a 3rd party mod integration tool for Deep Rock Galactic to download and integrate mods completely externally of the game. This enables more stable mod usage as well as offline mod usage.
    '';
    homepage = "https://github.com/trumank/mint";
    changelog = "https://github.com/trumank/mint/commit/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      gepbird
    ];
    mainProgram = "mint";
    platforms = [ "x86_64-linux" ];
  };
}
