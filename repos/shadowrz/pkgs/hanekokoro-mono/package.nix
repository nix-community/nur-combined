{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
  installFonts,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-mono";
  version = "0.2.4";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroMono.zip";
    stripRoot = false;
    hash = "sha256-ED2z3Ks3KCkP/eiHX/AfQSlEPEOr5eEuvScR4UJXFuo=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/hanekokoro-fonts";
    description = "A Custom Iosevka build";
  };
}
