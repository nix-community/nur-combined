{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "nats-manifests";
  inherit (nur.repos.josh.nats-chart) version;
  src = nur.repos.josh.nats-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "nats";
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
    description = "A Helm chart for the NATS.io High Speed Cloud Native Distributed Communications Technology.";
    homepage = "https://github.com/nats-io/k8s/tree/main/helm/charts/nats";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
