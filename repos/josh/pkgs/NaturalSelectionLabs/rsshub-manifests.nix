{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "rsshub-manifests";
  inherit (nur.repos.josh.rsshub-chart) version;
  src = nur.repos.josh.rsshub-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "rsshub";
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
    description = "A Helm chart for the RSSHub";
    homepage = "https://github.com/NaturalSelectionLabs/helm-charts/tree/main/charts/rsshub";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
  };
}
