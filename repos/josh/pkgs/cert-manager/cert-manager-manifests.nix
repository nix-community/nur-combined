{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "cert-manager-manifests";
  inherit (nur.repos.josh.cert-manager-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.cert-manager-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "cert-manager";
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
    description = "Kubernetes manifests for cert-manager, automating TLS certificate management on Kubernetes";
    homepage = "https://cert-manager.io";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
