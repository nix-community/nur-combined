{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "ceph-mgr-endpoint-controller-manifests";
  inherit (nur.repos.josh.ceph-mgr-endpoint-controller-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.ceph-mgr-endpoint-controller-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "ceph-mgr-endpoint-controller";
  helmArgs = [ ];
  helmValues = { };

  buildPhase = ''
    runHook preBuild
    export HELM_CACHE_HOME=$TMPDIR/cache
    export HELM_CONFIG_HOME=$TMPDIR/config
    export HELM_DATA_HOME=$TMPDIR/data
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
    description = "Kubernetes manifests for the Ceph manager endpoint controller";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller/tree/main/charts/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
