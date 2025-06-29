{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-sans";
  version = "0.2.0";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroSans.zip";
    stripRoot = false;
    hash = "sha256-yipZqbiZwxb5G1gQ/qhzPyAWidsuL4+q3y+bZXDtBKE=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    inherit (iosevka.meta) license platforms;
    homepage = "https://github.com/ShadowRZ/hanekokoro-fonts";
    description = "A Custom Iosevka build";
  };
}
