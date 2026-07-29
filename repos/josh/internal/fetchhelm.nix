{
  lib,
  callPackage,
  stdenvNoCC,
  kubernetes-helm,
}:
args@{
  pname ? "${chart}-chart",
  url,
  chart,
  version,
  hash,
  helmTestValues ? { },
  helmTestArgs ? [ ],
  meta ? { },
}:
let
  nixhelm-update = callPackage ./nixhelm-update.nix { };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  inherit pname version;

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = hash;
  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  nativeBuildInputs = [
    kubernetes-helm
  ];

  helmChart = chart;
  helmPullArgs =
    if (lib.strings.hasPrefix "oci://" url) then
      [
        url
        "--version"
        version
      ]
    else
      [
        chart
        "--repo"
        url
        "--version"
        version
      ];

  buildCommand = ''
    export HELM_CACHE_HOME=$TMPDIR/cache
    helm pull "''${helmPullArgs[@]}" --destination ./out --untar
    cp -R ./out/"$helmChart" $out
  '';

  passthru.updateScript = [
    "${lib.getExe nixhelm-update}"
    "--url"
    url
    "--chart"
    chart
  ];

  passthru.tests = {
    render = callPackage ./helm-render-template.nix {
      src = finalAttrs.finalPackage;
      chartName = chart;
      helmValues = helmTestValues;
      helmArgs = helmTestArgs;
    };
    images = callPackage ./check-kube-images.nix {
      src = finalAttrs.passthru.tests.render;
      inherit pname version;
    };
  };

  meta = {
    description = "${chart} Helm chart";
    platforms = lib.platforms.all;
  }
  // meta;

  # nixhelm-update locates the calling file via meta.position
  pos = builtins.unsafeGetAttrPos "url" args;
})
