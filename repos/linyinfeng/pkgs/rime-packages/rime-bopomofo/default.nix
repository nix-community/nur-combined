{ sources, stdenv, lib, rime-cangjie, rime-terra-pinyin }:

stdenv.mkDerivation {
  inherit (sources.rime-bopomofo) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  passthru.rimeDependencies = [
    rime-cangjie
    rime-terra-pinyin
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-bopomofo";
    description = "RIME Bopomofo input schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
