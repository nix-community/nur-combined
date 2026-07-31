{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "victoria-metrics-agent-manifests";
  inherit (nur.repos.josh.victoria-metrics-agent-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.victoria-metrics-agent-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "victoria-metrics-agent";
  helmArgs = [ ];
  helmValues = {
    remoteWrite = [
      { url = "http://victoria-metrics:8428"; }
    ];
  };

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
    description = "Kubernetes manifests for the VictoriaMetrics agent, collecting metrics and forwarding them to VictoriaMetrics";
    homepage = "https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-agent";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
