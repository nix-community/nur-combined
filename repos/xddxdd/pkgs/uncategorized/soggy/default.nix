{
  stdenv,
  sources,
  lib,
  cmake,
  protobuf3_21,
  protobufc,
  lua5_3_compat,
}:
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

    install -Dm755 soggy $out/bin/soggy
    install -Dm644 $src/soggy.cfg $out/opt/soggy.cfg
    cp -r $src/static $out/opt/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Experimental server emulator for a game I forgot its name";
    homepage = "https://github.com/LDAsuku/soggy";
    license = lib.licenses.agpl3Only;
    mainProgram = "soggy";
    broken = true;
  };
}
