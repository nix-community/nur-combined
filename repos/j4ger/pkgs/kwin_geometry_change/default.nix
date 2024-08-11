{
  lib,
  fetchFromGitHub,
  libsForQt5,
  stdenv
}:
let plasma-framework = libsForQt5.plasma-framework;
in
stdenv.mkDerivation rec {
  pname = "kwin_geometry_change";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "peterfajdiga";
    repo = "kwin4_effect_geometry_change";
    rev = "v${version}";
    hash = "sha256-H3cslx6ceAJGXSa0+gNzmUINRoLeYODhGt4pSFfgNbQ=";
  };

  buildInputs = [
    plasma-framework
  ];

  dontBuild = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    plasmapkg2 --install package --packageroot $out/share/kwin/effects

    runHook postInstall
  '';

  meta = with lib; {
    description = "A KWin animation for windows moved or resized by programs or scripts";
    license = licenses.gpl3Only;
    inherit (plasma-framework.meta) platforms;
  };
}
