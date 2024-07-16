{ lib, stdenv
, fetchFromGitHub
, gtk4-layer-shell
, gtkmm4
, pkg-config
, nix-update-script
, wireplumber
, wrapGAppsHook4
}:
stdenv.mkDerivation {
  pname = "syshud";
  version = "0-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syshud";
    rev = "bb4d8157ebb191d1b116d640c486762b4d697dff";
    hash = "sha256-KiySPiFKH3R65fgNYWlxrr/oOTNH1/JEGkyuP2MA6Lg=";
  };
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'pkg-config' ''${PKG_CONFIG}
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4  #< to plumb `GDK_PIXBUF_MODULE_FILE` through, and get not-blurry icons
  ];

  buildInputs = [
    gtk4-layer-shell
    gtkmm4
    wireplumber
  ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version" "branch" ];
  };

  meta = {
    description = "Simple heads up display written in gtkmm 4";
    homepage = "https://github.com/System64fumo/syshud";
    mainProgram = "syshud";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
