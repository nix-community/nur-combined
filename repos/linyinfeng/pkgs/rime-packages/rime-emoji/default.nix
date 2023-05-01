{ sources
, stdenv
, lib
}:

stdenv.mkDerivation {
  inherit (sources.rime-emoji) pname version src;

  installPhase = ''
    install -Dm644 emoji_suggestion.yaml -t "$out/share/rime-data/"
    install -Dm644 opencc/* -t "$out/share/rime-data/opencc/"
  '';

  meta = with lib; {
    homepage = "https://github.com/rime/rime-emoji";
    description = "RIME emoji input schema";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
