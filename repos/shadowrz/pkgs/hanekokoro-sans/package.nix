{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
  installFonts,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-sans";
  version = "0.2.4";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroSans.zip";
    stripRoot = false;
    hash = "sha256-Oz2b8HV7XSPIluuLd5Myj8b62eTzHEGgNxfTQvZ7hOE=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/hanekokoro-fonts";
    description = "A Custom Iosevka build";
  };
}
