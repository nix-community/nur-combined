{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
}:

stdenvNoCC.mkDerivation rec {
  pname = "iosevka-minoko-term";
  version = "0.1.7";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/iosevka-minoko/releases/download/v${version}/PkgTTF-IosevkaMinokoTerm.zip";
    stripRoot = false;
    hash = "sha256-qtWevV9yTgjYiPoNprr8J7cYqsJTqYzZZhO2wLy69Ow=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/iosevka-minoko";
    description = "A Custom Iosevka build";
  };
}
