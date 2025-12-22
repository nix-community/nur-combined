{
  lib,
  stdenvNoCC,
  fetchzip,
  iosevka,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanekokoro-mono-e";
  version = "0.2.2";

  src = fetchzip {
    url = "https://github.com/ShadowRZ/hanekokoro-fonts/releases/download/v${version}/PkgTTF-HanekokoroMonoE.zip";
    stripRoot = false;
    hash = "sha256-PreXgneZOAguHs9+fmAi7nKUR9RjW7893BR1wW2Nmhs=";
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
