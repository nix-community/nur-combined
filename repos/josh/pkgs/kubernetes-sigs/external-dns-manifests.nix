{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "external-dns-manifests";
  inherit (nur.repos.josh.external-dns-chart) version;
  src = nur.repos.josh.external-dns-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "external-dns";
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
    description = "ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers";
    homepage = "https://github.com/kubernetes-sigs/external-dns";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
