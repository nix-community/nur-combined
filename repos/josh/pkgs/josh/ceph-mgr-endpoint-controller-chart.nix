{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation {
  name = "ceph-mgr-endpoint-controller-chart";
  inherit (nur.repos.josh.ceph-mgr-endpoint-controller) src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/ceph-mgr-endpoint-controller/* $out/
  '';

  meta = {
    description = "A Helm chart for ceph-mgr-endpoint-controller";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller/tree/main/charts/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
