{
  sources,
  stdenv,
  lib,
  librime,
  rimeDataBuildHook,
  rime-prelude,
}:

stdenv.mkDerivation {
  inherit (sources.rime-ice) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [ rime-prelude ];

  installPhase = ''
    mkdir -p "$out/share/rime-data"
    cp -r cn_dicts "$out/share/rime-data/cn_dicts"
    cp -r en_dicts "$out/share/rime-data/en_dicts"
    cp -r opencc   "$out/share/rime-data/opencc"
    cp -r lua      "$out/share/rime-data/lua"

    install -Dm644 *.{schema,dict}.yaml -t "$out/share/rime-data/"
    install -Dm644 *.lua                -t "$out/share/rime-data/"
    install -Dm644 custom_phrase.txt    -t "$out/share/rime-data/"
    install -Dm644 symbols_v.yaml       -t "$out/share/rime-data/"
    install -Dm644 symbols_caps_v.yaml  -t "$out/share/rime-data/"

    install -Dm644 default.yaml "$out/share/rime-data/rime_ice_suggestion.yaml"

    install -Dm644 build/* -t "$out/share/rime-data/build"
  '';

  passthru.rimeDependencies = [ rime-prelude ];

  meta = with lib; {
    homepage = "https://github.com/iDvel/rime-ice";
    description = "A long-term maintained simplified Chinese RIME schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
