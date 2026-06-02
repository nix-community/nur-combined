{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "sops-secrets-operator-manifests";
  inherit (nur.repos.josh.sops-secrets-operator-chart) version;
  src = nur.repos.josh.sops-secrets-operator-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "sops-secrets-operator";
  helmArgs = [
    "--kube-version"
    "1.36.0"
  ];
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
    description = "Helm chart deploys sops-secrets-operator";
    homepage = "https://github.com/isindir/sops-secrets-operator/tree/master/chart/helm3/sops-secrets-operator";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
}
