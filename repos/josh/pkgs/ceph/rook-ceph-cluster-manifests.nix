{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rook-ceph-cluster-manifests";
  inherit (nur.repos.josh.rook-ceph-cluster-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.rook-ceph-cluster-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "rook-ceph-cluster";
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
    cp -R ./"$helmChartName"/. $out/
    runHook postInstall
  '';

  passthru.tests = {
    parse =
      runCommand "test-rook-ceph-cluster-manifests-parse"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ yq ];
        }
        ''
          find ${finalAttrs.finalPackage} \( -name '*.yaml' -o -name '*.yml' \) -exec yq -r '.kind? // empty' {} + >kinds.txt
          grep -q . kinds.txt
          touch $out
        '';
  };

  meta = {
    description = "Kubernetes manifests creating Rook resources to configure a Ceph cluster";
    homepage = "https://github.com/rook/rook";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
