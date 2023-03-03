{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-prelude) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  passthru.rimeDependencies = [ ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-prelude";
    description = "Essential files for building up your Rime configuration";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
