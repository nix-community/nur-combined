{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-cpu-core-load";
  version = "0-unstable-2026-05-28";

  src = fetchFromGitHub {
    owner = "rabits";
    repo = "dms-plugin-cpucoreload";
    rev = "c0b1399eaf452abc04060c734fece535f8e08320";
    hash = "sha256-Y2xJkMsQ02JVCIxwGFh29Ps5UQJvz+xnfIOjStjztWc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing per-CPU-core load as bars";
    homepage = "https://github.com/rabits/dms-plugin-cpucoreload";
    license = licenses.asl20;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
