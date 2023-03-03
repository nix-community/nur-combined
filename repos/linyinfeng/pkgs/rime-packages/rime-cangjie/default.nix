{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-cangjie) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/rime/rime-cangjie";
    description = "RIME Cangjie input schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
