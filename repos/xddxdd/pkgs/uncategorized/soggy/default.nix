{
  stdenv,
  sources,
  lib,
  cmake,
  protobuf3_21,
  protobufc,
  lua5_3_compat,
  ...
}@args:
stdenv.mkDerivation rec {
  inherit (sources.soggy) pname version src;
  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    protobuf3_21
    protobufc
    lua5_3_compat
  ];

  patches = [ ./fix-cstdint-include.patch ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp soggy $out/bin/
    cp $src/soggy.cfg $out/opt/
    cp -r $src/static $out/opt/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Experimental server emulator for a game I forgot its name";
    homepage = "https://github.com/LDAsuku/soggy";
    license = licenses.agpl3Only;
  };
}
