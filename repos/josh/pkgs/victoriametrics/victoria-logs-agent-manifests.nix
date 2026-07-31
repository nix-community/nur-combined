{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "victoria-logs-agent-manifests";
  inherit (nur.repos.josh.victoria-logs-agent-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.victoria-logs-agent-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "victoria-logs-agent";
  helmArgs = [ ];
  helmValues = {
    remoteWrite = [
      { url = "http://victoria-logs:9428"; }
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
    cp -R ./"$helmChartName"/. $out/
    runHook postInstall
  '';

  passthru.tests = {
    parse =
      runCommand "test-victoria-logs-agent-manifests-parse"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ yq ];
        }
        ''
          find ${finalAttrs.finalPackage} \( -name '*.yaml' -o -name '*.yml' \) -exec yq -r '.kind? // empty' {} + >kinds.txt
          grep -q . kinds.txt
          touch $out
        '';
  };

  meta = {
    description = "Kubernetes manifests for the VictoriaLogs agent, replicating logs across VictoriaLogs instances";
    homepage = "https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-logs-agent";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
