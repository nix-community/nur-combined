{
  stdenv,
  sources,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.route-chain) pname version src;
  enableParallelBuilding = true;
  installPhase = ''
    runHook preInstall

    make install PREFIX=$out

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Small app to generate a long path in traceroute";
    homepage = "https://github.com/xddxdd/route-chain";
    license = lib.licenses.unlicense;
    mainProgram = "route-chain";
  };
})
