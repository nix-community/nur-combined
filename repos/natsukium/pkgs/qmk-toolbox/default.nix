{
  source,
  lib,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  preferLocalBuild = true;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    unzip $src
    mkdir -p $out/Applications/QMK\ Toolbox.app
    cp -r Contents $out/Applications/QMK\ Toolbox.app/Contents

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Toolbox companion for QMK Firmware";
    homepage = "https://github.com/qmk/qmk_toolbox";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
