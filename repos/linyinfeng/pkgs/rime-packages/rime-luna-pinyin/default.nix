{ sources, stdenv, lib }:

stdenv.mkDerivation {
  inherit (sources.rime-luna-pinyin) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/rime/rime-luna-pinyin";
    description = "Luna pinyin for RIME";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
