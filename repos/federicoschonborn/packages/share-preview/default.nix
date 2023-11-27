{ lib
, stdenv
, fetchFromGitHub
, cargo
, curl
, desktop-file-utils
, libadwaita
, meson
, ninja
, openssl
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
, zlib
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "share-preview";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "share-preview";
    rev = finalAttrs.version;
    hash = "sha256-epN2YOaDrvdQwaUnIarnRTcHk5dhp6Ea29/37cliBes=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-tMb6zs5jJJyECDuAbzoOrB2H2/wPL8MEQOOWZ9rF66E=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    curl
    libadwaita
    openssl
    zlib
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Test social media cards locally";
    homepage = "https://github.com/rafaelmardojai/share-preview";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
