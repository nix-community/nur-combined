{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "cilium-manifests";
  inherit (nur.repos.josh.cilium-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.cilium-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "cilium";
  helmArgs = [ ];
  helmValues = { };
  helmOutputDir = true;

  buildPhase = ''
    runHook preBuild
    export HELM_CACHE_HOME=$TMPDIR/cache
    yq --yaml-output '.helmValues' "$NIX_ATTRS_JSON_FILE" >values.yaml
    if [ -n "$helmOutputDir" ]; then
      helm template "$helmChartName" "$src" --output-dir . --values values.yaml "''${helmArgs[@]}"
    else
      helm template "$helmChartName" "$src" --values values.yaml "''${helmArgs[@]}" >manifests.yaml
    fi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    if [ -n "$helmOutputDir" ]; then
      mkdir -p $out
      cp -R ./"$helmChartName"/* $out
    else
      cp manifests.yaml $out
    fi
    runHook postInstall
  '';

  meta = {
    description = "Kubernetes manifests for Cilium, eBPF-based networking, observability, and security";
    homepage = "https://github.com/cilium/cilium";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
