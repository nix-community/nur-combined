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
  version = "0.2.10-unstable-2025-05-04";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "6335041f21b95976d29fe2cfbf282feb0c9f38ac";
    hash = "sha256-OyfLyAOMSrvXkyGL+PkyrZ7PLBgQ040SCv9Q85AkX+o=";
    deepClone = true;
    postFetch = ''
      echo -n $(git -C $out describe) > $out/GIT_VERSION
      rm -rf $out/.git
    '';
  };

  patches = [
    # https://github.com/rust-lang/rust/issues/51114
    ./0001-Drop-usage-of-unstable-if_let_guard-feature.patch
    # TODO: remove in rust 1.88.0: https://github.com/rust-lang/rust/pull/132833
    ./0002-Drop-usage-of-unstable-let_chains-feature.patch
  ];

  preConfigure = ''
    export BUILT_OVERRIDE_mint_lib_GIT_VERSION=$(cat GIT_VERSION)
    echo "Using mint_lib GIT_VERSION: $BUILT_OVERRIDE_mint_lib_GIT_VERSION"
  '';

  useFetchCargoVendor = true;
  cargoHash = "sha256-E6pdDUrmmq8EhMFbfP7UTZ1+yysCCn7yc1/MO5jEVEw=";

  buildNoDefaultFeatures = true;
  # remove "hook" which is used to build a necessary .dll
  # it requires nightly rust toolchain and mingw windows cross compiler
  buildFeatures = [ "oodle_platform_dependent" ];

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
