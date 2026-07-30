{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "tailscale-operator-manifests";
  inherit (nur.repos.josh.tailscale-operator-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.tailscale-operator-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "tailscale-operator";
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
    description = "Kubernetes manifests for the Tailscale Kubernetes operator";
    homepage = "https://github.com/tailscale/tailscale/tree/main/cmd/k8s-operator/deploy/chart";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
