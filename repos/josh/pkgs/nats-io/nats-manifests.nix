{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "nats-manifests";
  inherit (nur.repos.josh.nats-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.nats-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "nats";
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
    description = "Kubernetes manifests for NATS, a cloud native messaging system";
    homepage = "https://github.com/nats-io/k8s/tree/main/helm/charts/nats";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
