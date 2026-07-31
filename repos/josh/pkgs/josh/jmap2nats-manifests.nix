{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "jmap2nats-manifests";
  inherit (nur.repos.josh.jmap2nats-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.jmap2nats-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "jmap2nats";
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
    description = "Kubernetes manifests for jmap2nats";
    homepage = "https://github.com/josh/jmap2nats/tree/main/charts/jmap2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
