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
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "mint-mod-manager";
  version = "0.2.10-unstable-2024-12-13";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "f4b7bcd3fd216a78cfb87bd88b961bc899521f78";
    hash = "sha256-q0nIpuh24hsMbMkPttjFiO7XpvtbKLZO/kPxOCo0G+8=";
  };

  patches = [
    ./0001-Drop-usage-of-unstable-if_let_guard-feature.patch
    ./0002-Drop-usage-of-unstable-let_chains-feature.patch
  ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-bUFiDr+ogOTYmTU89xzFSXD2ZHPTk7N7V2erHsFB3lE=";

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

  passthru.updateScript = nix-update-script { };

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
