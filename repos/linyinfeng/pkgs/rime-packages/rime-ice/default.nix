{ sources, stdenv, lib, rime-prelude }:

stdenv.mkDerivation {
  inherit (sources.rime-ice) pname version src;

  installPhase = ''
    install -Dm644 cn_dicts/* -t "$out/share/rime-data/cn_dicts"
    install -Dm644 en_dicts/* -t "$out/share/rime-data/en_dicts"
    install -Dm644 opencc/*   -t "$out/share/rime-data/opencc"

    install -Dm644 *.{schema,dict}.yaml  -t "$out/share/rime-data/"
    install -Dm644 *.{lua,gram}          -t "$out/share/rime-data/"
    install -Dm644 symbols_custom.yaml   -t "$out/share/rime-data/"
  '';

  passthru.rimeDependencies = [ rime-prelude ];

  meta = with lib; {
    homepage = "https://github.com/iDvel/rime-ice";
    description = "A long-term maintained simplified Chinese RIME schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
