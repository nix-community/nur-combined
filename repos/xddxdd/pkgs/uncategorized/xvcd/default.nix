{
  sources,
  lib,
  stdenv,
  libftdi,
}:
stdenv.mkDerivation rec {
  inherit (sources.xvcd) pname version src;
  sourceRoot = "source/linux";

  buildInputs = [ libftdi ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/xvcd $out/bin/xvcd

    runHook postInstall
  '';

  meta = {
    mainProgram = "xvcd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Xilinx Virtual Cable Daemon";
    homepage = "https://github.com/RHSResearchLLC/xvcd";
    license = lib.licenses.cc0;
  };
}
