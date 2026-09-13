{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-recent-files";
  version = "0-unstable-2026-07-13";

  src = fetchFromGitHub {
    owner = "gouwazi";
    repo = "dms-recent-files";
    rev = "15010449df58ffec4f85acd48f8ee1145de31a1a";
    hash = "sha256-zAzkM1oO50Opja8OskXyCQ7ma3eT+1fikb7bmguG8eM=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to search recently opened XDG files";
    homepage = "https://github.com/gouwazi/dms-recent-files";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
