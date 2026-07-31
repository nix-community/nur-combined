{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "victoria-metrics-single-manifests";
  inherit (nur.repos.josh.victoria-metrics-single-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.victoria-metrics-single-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "victoria-metrics-single";
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
    description = "Kubernetes manifests for single-node VictoriaMetrics, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-single";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
