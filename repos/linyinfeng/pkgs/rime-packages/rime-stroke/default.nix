{
  sources,
  stdenv,
  lib,
  librime,
  rimeDataBuildHook,
  rime-luna-pinyin,
  rime-prelude,
  rime-essay,
}:

stdenv.mkDerivation {
  inherit (sources.rime-stroke) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [
    rime-prelude
    rime-essay
  ];

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [ rime-luna-pinyin ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-stroke";
    description = "RIME Stroke input schema";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
