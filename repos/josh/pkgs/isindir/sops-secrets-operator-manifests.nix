{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sops-secrets-operator-manifests";
  inherit (nur.repos.josh.sops-secrets-operator-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.sops-secrets-operator-chart;

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

  passthru.tests = {
    parse =
      runCommand "test-sops-secrets-operator-manifests-parse"
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
    description = "Kubernetes manifests for the sops secrets operator, decrypting sops-encrypted Kubernetes secrets";
    homepage = "https://github.com/isindir/sops-secrets-operator/tree/master/chart/helm3/sops-secrets-operator";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
