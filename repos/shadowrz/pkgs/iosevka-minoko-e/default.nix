{ lib, stdenvNoCC, fetchzip, iosevka }:

stdenvNoCC.mkDerivation rec {
  pname = "iosevka-minoko-e";
  version = "0.1.4";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/iosevka-minoko/releases/download/v${version}/PkgTTF-IosevkaMinokoE.zip";
    stripRoot = false;
    hash = "sha256-bk51AbwWLn0AenXRGiBmkx/763GLvrksWXJDSufOKz4=";
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

