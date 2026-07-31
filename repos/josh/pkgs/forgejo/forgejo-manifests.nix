{
  lib,
  stdenvNoCC,
  nur,
  kubernetes-helm,
  yq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "forgejo-manifests";
  inherit (nur.repos.josh.forgejo-chart) version;

  __structuredAttrs = true;

  src = nur.repos.josh.forgejo-chart;

  nativeBuildInputs = [
    kubernetes-helm
    yq
  ];

  helmChartName = "forgejo";
  helmArgs = [ ];
  helmValues = {
    gitea = {
      admin = {
        username = "";
        password = "";
      };
    };
  };

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
      runCommand "test-forgejo-manifests-parse"
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
    description = "Kubernetes manifests for Forgejo, a self-hosted Git forge";
    homepage = "https://code.forgejo.org/forgejo-helm/forgejo-helm";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
