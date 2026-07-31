{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "cloudnative-pg-manifests";
  inherit (nur.repos.josh.cloudnative-pg-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.cloudnative-pg-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "cloudnative-pg";
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
    description = "Kubernetes manifests for the CloudNativePG operator";
    homepage = "https://cloudnative-pg.io";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
