{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "cilium-manifests";
  inherit (nur.repos.josh.cilium-chart) version;
  src = nur.repos.josh.cilium-chart;

  __structuredAttrs = true;

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
    description = "Cilium - eBPF-based Networking, Observability, and Security";
    homepage = "https://github.com/cilium/cilium";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
