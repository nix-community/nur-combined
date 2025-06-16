{
  sources,
  stdenv,
  lib,
  rime-luna-pinyin,
  rime-bopomofo,
  rime-cangjie,
  rime-stroke,
  rime-terra-pinyin,
}:

stdenv.mkDerivation {
  inherit (sources.rime-prelude) pname version src;

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  passthru.rimeDependencies = [
    rime-luna-pinyin
    rime-bopomofo
    rime-cangjie
    rime-stroke
    rime-terra-pinyin
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-prelude";
    description = "Essential files for building up your Rime configuration";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
