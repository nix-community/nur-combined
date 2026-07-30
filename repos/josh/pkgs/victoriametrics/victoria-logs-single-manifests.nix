{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "victoria-logs-single-manifests";
  inherit (nur.repos.josh.victoria-logs-single-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.victoria-logs-single-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "victoria-logs-single";
  helmArgs = [ ];
  helmValues = { };

  buildPhase = ''
    runHook preBuild
    export HELM_CACHE_HOME=$TMPDIR/cache
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
    description = "Kubernetes manifests for a single-node VictoriaLogs database";
    homepage = "https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-logs-single";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
