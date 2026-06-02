{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "ceph-csi-cephfs-manifests";
  inherit (nur.repos.josh.ceph-csi-cephfs-chart) version;
  src = nur.repos.josh.ceph-csi-cephfs-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "ceph-csi-cephfs";
  helmArgs = [ ];
  helmValues = { };

  buildPhase = ''
    runHook preBuild
    yq --yaml-output '.helmValues' "$NIX_ATTRS_JSON_FILE" >values.yaml
    helm template "$helmChartName" "$src" --output-dir . --values values.yaml "''${helmArgs[@]}"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R ./"$helmChartName"/* $out
    runHook postInstall
  '';

  meta = {
    description = "Container Storage Interface (CSI) driver, provisioner, snapshotter, resizer and attacher for Ceph cephfs";
    homepage = "https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-cephfs";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
