{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "gha-runner-scale-set-controller-manifests";
  inherit (nur.repos.josh.gha-runner-scale-set-controller-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.gha-runner-scale-set-controller-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "gha-runner-scale-set-controller";
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
    description = "Kubernetes manifests for the GitHub Actions runner scale set controller";
    homepage = "https://github.com/actions/actions-runner-controller";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
