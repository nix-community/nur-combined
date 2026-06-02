{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "cloudnative-pg-manifests";
  inherit (nur.repos.josh.cloudnative-pg-chart) version;
  src = nur.repos.josh.cloudnative-pg-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "cloudnative-pg";
  helmArgs = [ ];
  helmValues = { };

  buildPhase = ''
    runHook preBuild
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
    description = "CloudNativePG Helm Charts";
    homepage = "https://github.com/cloudnative-pg/charts";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
