{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "external-dns-manifests";
  inherit (nur.repos.josh.external-dns-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.external-dns-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "external-dns";
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
    description = "Kubernetes manifests for ExternalDNS, which synchronizes exposed Kubernetes Services and Ingresses with DNS providers";
    homepage = "https://github.com/kubernetes-sigs/external-dns";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
