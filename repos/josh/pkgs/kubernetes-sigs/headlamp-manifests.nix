{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "headlamp-manifests";
  inherit (nur.repos.josh.headlamp-chart) version;
  src = nur.repos.josh.headlamp-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "headlamp";
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
    description = "Headlamp is an easy-to-use and extensible Kubernetes web UI";
    homepage = "https://github.com/kubernetes-sigs/headlamp/tree/main/charts/headlamp";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
