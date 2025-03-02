{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  gtk3,
  libnotify,
  mate,
  nix-update-script,
}:

let
  version = "0.6.2";
in

stdenv.mkDerivation {
  pname = "brisk-menu";
  inherit version;

  src = fetchFromGitHub {
    owner = "getsolus";
    repo = "brisk-menu";
    rev = "refs/tags/v${version}";
    hash = "sha256-e7ETdVv0/9UFyfLFQiZalxCEiVaOWYq+0Cv3BTvYecU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk3
    libnotify
    mate.mate-menus
    mate.mate-panel
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An efficient menu for the MATE Desktop";
    homepage = "https://github.com/getsolus/brisk-menu";
    license = with lib.licenses; [
      gpl2Only
      cc-by-sa-40
    ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
