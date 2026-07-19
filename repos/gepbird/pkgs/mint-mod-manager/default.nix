{
  pkgs,
  lib,
  fetchFromGitHub,
  fetchpatch,
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
rustPlatform.buildRustPackage (finalAttrs: {
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

  patches = [
    (fetchpatch {
      name = "fix-mod.io-403-error.patch";
      url = "https://github.com/Wasserkleber/mintfixed/commit/0170376189d46fc8f7b627f8ee0dcdf7b0b2c2ad.patch";
      hash = "sha256-q+NasQ4xyI+E+ucBw5kJ/MHnZR9ydFxBc6AY9NEVQ04=";
    })
  ];

  cargoHash = "sha256-5EYSiUTa50gMu2YHx6COVJU+8IFuvc5td/9TzygpeaY=";

  env = {
    # Necessary for cross compiled build scripts, otherwise it will build as ELF format
    # https://docs.rs/cc/latest/cc/#external-configuration-via-environment-variables
    CC_x86_64_pc_windows_gnu = "${mingwCompiler}/bin/${mingwCompiler.targetPrefix}cc";
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS = "-L ${mingwPkgs.windows.pthreads}/lib";
  };

  preConfigure = ''
    export BUILT_OVERRIDE_mint_lib_GIT_VERSION=$(cat GIT_VERSION)
    echo "Using mint_lib GIT_VERSION: $BUILT_OVERRIDE_mint_lib_GIT_VERSION"
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Deep Rock Galactic mod loader and integration";
    longDescription = ''
      Mint is a 3rd party mod integration tool for Deep Rock Galactic to download and integrate mods completely externally of the game. This enables more stable mod usage as well as offline mod usage.
    '';
    homepage = "https://github.com/trumank/mint";
    changelog = "https://github.com/trumank/mint/commit/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      gepbird
    ];
    mainProgram = "mint";
    platforms = [ "x86_64-linux" ];
  };
})
