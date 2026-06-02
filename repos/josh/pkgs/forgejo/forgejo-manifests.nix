{
  lib,
  stdenvNoCC,
  kubernetes-helm,
  yq,
  nur,
}:
stdenvNoCC.mkDerivation {
  pname = "forgejo-manifests";
  inherit (nur.repos.josh.forgejo-chart) version;
  src = nur.repos.josh.forgejo-chart;

  __structuredAttrs = true;

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
    description = "Forgejo Helm chart";
    homepage = "https://code.forgejo.org/forgejo-helm/forgejo-helm";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
