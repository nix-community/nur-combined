{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
  installFonts,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-mono-e";
  version = "0.2.4";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroMonoE.zip";
    stripRoot = false;
    hash = "sha256-+ldcMPpLLF718L7Bjw7lAeJd/apKo6S54oIhGkbpknY=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/hanekokoro-fonts";
    description = "A Custom Iosevka build";
  };
}
