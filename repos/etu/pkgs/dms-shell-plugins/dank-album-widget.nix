{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-album-widget";
  version = "0-unstable-2026-08-29";

  src = fetchFromGitHub {
    owner = "kmf";
    repo = "dank-album-widget";
    rev = "433d85bf6309e155f23c626590bf1f3f579d2770";
    hash = "sha256-4HLMX5n0X3S6NnW5bgSei8NjtmBDoZjUcoZjLK4+9bM=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell square album-cover desktop widget with Material play, previous, and next controls over MPRIS";
    homepage = "https://github.com/kmf/dank-album-widget";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
