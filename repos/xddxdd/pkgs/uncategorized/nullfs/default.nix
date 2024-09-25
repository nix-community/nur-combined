{
  stdenv,
  sources,
  lib,
  fuse,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.nullfs) pname version src;

  buildInputs = [ fuse ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 nul1fs nullfs nulnfs $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FUSE nullfs drivers";
    homepage = "https://github.com/xrgtn/nullfs";
    license = with lib.licenses; [ gpl1Only ];
  };
}
