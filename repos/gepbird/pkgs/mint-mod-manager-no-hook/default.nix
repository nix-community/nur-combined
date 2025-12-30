{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  gtk3,
  libGL,
  openssl,
  atk,
  libxkbcommon,
  wayland,
}:

rustPlatform.buildRustPackage rec {
  pname = "mint-mod-manager-no-hook";
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
    # https://github.com/rust-lang/rust/issues/51114
    ./0001-Drop-usage-of-unstable-if_let_guard-feature.patch
  ];

  preConfigure = ''
    export BUILT_OVERRIDE_mint_lib_GIT_VERSION=$(cat GIT_VERSION)
    echo "Using mint_lib GIT_VERSION: $BUILT_OVERRIDE_mint_lib_GIT_VERSION"
  '';

  cargoHash = "sha256-5EYSiUTa50gMu2YHx6COVJU+8IFuvc5td/9TzygpeaY=";

  # remove "hook" which is used to build a necessary .dll
  # it requires nightly rust toolchain and mingw windows cross compiler
  buildNoDefaultFeatures = true;

  nativeBuildInputs = [
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
    description = "Deep Rock Galactic mod loader and integration (no hook)";
    longDescription = ''
      Mint is a 3rd party mod integration tool for Deep Rock Galactic to download and integrate mods completely externally of the game. This enables more stable mod usage as well as offline mod usage.

      Use mint-mod-manager for personal use. The absence of the hook feature means mod install won't work for the first time, you will get a "Mint hook failed" error in game. With hook, it would install the necessary x3daudio1_7.dll file. This package only exists because it has a simpler build script.
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
