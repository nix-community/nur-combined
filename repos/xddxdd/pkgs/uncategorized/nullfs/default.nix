{
  stdenv,
  sources,
  lib,
  fuse,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.nullfs) pname version src;

  patches = [ ./6-nulnfs-fix-warnings.patch ];

  buildInputs = [ fuse ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 nul1fs nullfs nulnfs $out/bin/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FUSE nullfs drivers";
    homepage = "https://github.com/xrgtn/nullfs";
    license = with lib.licenses; [ gpl1Only ];
    mainProgram = "nullfs";
  };
})
