{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "gitea-manifests";
  inherit (nur.repos.josh.gitea-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.gitea-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "gitea";
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
    description = "Kubernetes manifests for Gitea, a self-hosted Git service";
    homepage = "https://gitea.com/gitea/helm-gitea";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
