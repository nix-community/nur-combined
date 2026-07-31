{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nack-manifests";
  inherit (nur.repos.josh.nack-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.nack-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "nack";
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
    cp -R ./"$helmChartName"/. $out/
    runHook postInstall
  '';

  passthru.tests = {
    parse =
      runCommand "test-nack-manifests-parse"
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
    description = "Kubernetes manifests for NACK, the NATS controller for Kubernetes";
    homepage = "https://github.com/nats-io/k8s/tree/main/helm/charts/nack";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
