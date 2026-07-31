{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "rsshub-manifests";
  inherit (nur.repos.josh.rsshub-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.rsshub-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "rsshub";
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
    description = "Kubernetes manifests for RSSHub, an extensible RSS feed generator";
    homepage = "https://github.com/NaturalSelectionLabs/helm-charts/tree/main/charts/rsshub";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
