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
  pname = "mint-mod-manager";
  version = "0.2.10-unstable-2025-04-23";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "276bf5fdbf6dd7b14e989f9849ea465fe9c88465";
    hash = "sha256-4/NcubWmkRDR44Ud50SNvTxNZxCkAE6ZLeK6yHtAuZU=";
    deepClone = true;
    postFetch = ''
      echo -n $(git -C $out describe) > $out/mint_lib/src/GIT_VERSION
      rm -rf $out/.git
    '';
  };

  patches = [
    # https://github.com/rust-lang/rust/issues/51114
    ./0001-Drop-usage-of-unstable-if_let_guard-feature.patch
    # TODO: remove in rust 1.88.0: https://github.com/rust-lang/rust/pull/132833
    ./0002-Drop-usage-of-unstable-let_chains-feature.patch
    # this can be upstreamed
    ./0003-Use-built_info-version-rather-than-built_info-GIT_VE.patch
    # https://github.com/lukaslueg/built/issues/77
    ./0004-Use-GIT_VERSION-file-instead-builts.rs-s-GIT_VERSION.patch
  ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-cYjaRbbwK6Amd47PlCWIkv12oXauRcWXHU1/dWYTiI0=";

  buildNoDefaultFeatures = true;
  buildFeatures = [ "oodle_platform_dependent" ]; # remove "hook" which is used for windows

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
