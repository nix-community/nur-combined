{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
}:
stdenvNoCC.mkDerivation {
  pname = "nats-static-manifests";
  inherit (nur.repos.josh.nats-static) version;

  __structuredAttrs = true;

  inherit (nur.repos.josh.nats-static) src;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "nats-static";
  helmArgs = [ ];
  helmValues = { };

  buildPhase = ''
    runHook preBuild
    export HELM_CACHE_HOME=$TMPDIR/cache
    yq --yaml-output '.helmValues' "$NIX_ATTRS_JSON_FILE" >values.yaml
    helm template "$helmChartName" "$src/charts/nats-static" --output-dir . --values values.yaml "''${helmArgs[@]}"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R ./"$helmChartName"/* $out
    runHook postInstall
  '';

  meta = {
    description = "Kubernetes manifests for nats-static";
    homepage = "https://github.com/josh/nats-static/tree/main/charts/nats-static";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
