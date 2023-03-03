{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-essay) pname version src;

  installPhase = ''
    install -Dm644 *.txt -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/rime/rime-essay";
    description = "RIME Essay input schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
