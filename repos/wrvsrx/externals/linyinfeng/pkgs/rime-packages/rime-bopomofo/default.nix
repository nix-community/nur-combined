{
  sources,
  stdenv,
  lib,
  librime,
  rimeDataBuildHook,
  rime-stroke,
  rime-terra-pinyin,
  rime-prelude,
  rime-essay,
}:

stdenv.mkDerivation {
  inherit (sources.rime-bopomofo) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [
    rime-prelude
    rime-essay
  ];

  propagatedBuildInputs = [ rime-terra-pinyin ];

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [
    # dependency for reverse lookup
    rime-stroke
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-bopomofo";
    description = "RIME Bopomofo input schema";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
