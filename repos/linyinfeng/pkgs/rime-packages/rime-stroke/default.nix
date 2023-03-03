{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-stroke) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/rime/rime-stroke";
    description = "RIME Stroke input schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
