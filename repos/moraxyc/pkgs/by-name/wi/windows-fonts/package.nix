{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "windows-fonts";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/Moraxyc/Windows-Fonts-CN/releases/download/v${version}/Windows11-truetype.tar.xz";
    hash = "sha256-3Uv0qmGpTaH++S0qeeQttgIePHWUDxUaYqGuzttsadM=";
  };

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    find . -name '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.ttc'    -exec install -Dt $out/share/fonts/truetype {} \;

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Moraxyc/Windows-Fonts-CN";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
