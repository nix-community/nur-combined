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
  version = "0-unstable-2024-07-02";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syshud";
    rev = "90e8fd02a677b180eed0492ca679f9ab4cf36f29";
    hash = "sha256-TNlYS8FNDYmn+Z3n591kXryQnFcmuuPWPiZ4q9/+StE=";
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
