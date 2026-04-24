{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "asap-condensed";
  version = "3.001";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fonts";
    rev = "46d8a043641ec6f446cddf39749c0b8d0dc71467";
    sparseCheckout = [ "ofl/asapcondensed" ];
    hash = "sha256-c4n8pJmeODmaH0l7NOz4MbhQuzfMaYvF2lqy5qfuK5o=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 ofl/asapcondensed/*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = with lib; {
    description = "Asap Condensed font family";
    homepage = "https://fonts.google.com/specimen/Asap+Condensed";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = [ lib.maintainers.lunik1 ];
  };
}
