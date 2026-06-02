{
  stdenvNoCC,
  kubernetes-helm,
  yq,
  src,
  chartName,
  helmReleaseName ? chartName,
  helmValues ? { },
  helmArgs ? [ ],
}:
stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  inherit (src) name;
  inherit src;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  inherit helmReleaseName helmValues helmArgs;

  buildPhase = ''
    runHook preBuild
    yq --yaml-output '.helmValues' "$NIX_ATTRS_JSON_FILE" >values.yaml
    export HELM_CACHE_HOME=$TMPDIR/cache
    helm template "$helmReleaseName" "$src" --output-dir ./out --values values.yaml "''${helmArgs[@]}"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R ./out/"${chartName}"/* $out
    runHook postInstall
  '';
}
