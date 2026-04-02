{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
  installFonts,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-mono-k";
  version = "0.2.4";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroMonoK.zip";
    stripRoot = false;
    hash = "sha256-VpLN9ykS1dkMh45Dhll9YOQv0hTxooABLcdwKtu5Zuk=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/hanekokoro-fonts";
    description = "A Custom Iosevka build";
  };
}
