{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-prelude
, rime-essay
, rime-cangjie
}:

stdenv.mkDerivation {
  inherit (sources.rime-loengfan) pname version src;

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

  passthru.rimeDependencies = [
    # dependencies for reverse lookup
    rime-cangjie
  ];

  meta = with lib; {
    homepage = "https://github.com/CanCLID/rime-loengfan";
    description = "Loengfan is the Cantonese version of the Liang Fen input method";
    license = licenses.cc-by-40;
    maintainers = with maintainers; [ yinfeng ];
  };
}
