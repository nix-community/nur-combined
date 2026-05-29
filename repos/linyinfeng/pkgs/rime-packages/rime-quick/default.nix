{
  sources,
  stdenv,
  lib,
  librime,
  rimeDataBuildHook,
  rime-luna-pinyin,
  rime-essay,
  rime-prelude,
  rime-cangjie,
}:

stdenv.mkDerivation {
  inherit (sources.rime-quick) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [
    rime-prelude
    rime-essay
    rime-cangjie
  ];

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [ rime-luna-pinyin ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-quick";
    description = "Rime Quick input method";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
