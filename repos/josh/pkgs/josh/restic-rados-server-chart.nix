{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation {
  name = "restic-rados-server-chart";
  inherit (nur.repos.josh.restic-rados-server) src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/restic-rados-server/* $out/
  '';

  meta = {
    description = "A Helm chart for restic-rados-server";
    homepage = "https://github.com/josh/restic-rados-server/tree/main/charts/restic-rados-server";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
