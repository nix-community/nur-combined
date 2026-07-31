{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "victoria-metrics-operator-manifests";
  inherit (nur.repos.josh.victoria-metrics-operator-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.victoria-metrics-operator-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "victoria-metrics-operator";
  helmArgs = [ ];
  helmValues = {
    admissionWebhooks.certManager.enabled = true;
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

  passthru.tests = {
    parse =
      runCommand "test-victoria-metrics-operator-manifests-parse"
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
    description = "Kubernetes manifests for the VictoriaMetrics operator";
    homepage = "https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-operator";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
