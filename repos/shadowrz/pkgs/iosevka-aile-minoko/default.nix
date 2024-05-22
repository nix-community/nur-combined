{ lib, stdenvNoCC, fetchzip, iosevka }:

stdenvNoCC.mkDerivation rec {
  pname = "iosevka-aile-minoko";
  version = "0.1.2";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/iosevka-minoko/releases/download/v${version}/PkgTTF-IosevkaAileMinoko.zip";
    stripRoot = false;
    hash = "sha256-nADfnAZQ3onWmlYcj8roVAAkAPCg6rGzQV8kD9KZ5R8=";
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

