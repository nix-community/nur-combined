{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "gha-runner-scale-set-controller-manifests";
  inherit (nur.repos.josh.gha-runner-scale-set-controller-chart) version;
  src = nur.repos.josh.gha-runner-scale-set-controller-chart;

  __structuredAttrs = true;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "gha-runner-scale-set-controller";
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
    description = "Actions Runner Controller - Kubernetes controller for GitHub Actions self-hosted runners";
    homepage = "https://github.com/actions/actions-runner-controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
