{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "external-secrets-manifests";
  inherit (nur.repos.josh.external-secrets-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.external-secrets-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "external-secrets";
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
    description = "External Secrets Operator - Integrates external secret management systems with Kubernetes";
    homepage = "https://github.com/external-secrets/external-secrets";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
