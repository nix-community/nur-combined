{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-essay) pname version src;

  installPhase = ''
    install -Dm644 *.txt -t "$out/share/rime-data/"
  '';

  passthru.rimeDependencies = [ ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-essay";
    description = "Essay - the shared vocabulary and language model";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
