{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "victoria-metrics-dashboards";
  version = "1.149.0-cluster";

  outputs = [
    "out"
    "prometheus"
    "vm"
  ];

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaMetrics";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ywHDOJRhr1tk9F3z5FjUH8oWs7OajdKB1iO5RH3MCqc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out $prometheus $vm
    cp ./dashboards/*.json $out/
    cp ./dashboards/*.json $prometheus/
    cp ./dashboards/vm/*.json $vm/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex"
      "v([0-9.]+-cluster)"
    ];
  };

  passthru.tests = {
    json =
      runCommand "test-victoria-metrics-dashboards-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage} ${finalAttrs.finalPackage.prometheus} ${finalAttrs.finalPackage.vm} -name '*.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" >/dev/null
          touch $out
        '';
  };

  meta = {
    description = "Grafana dashboards for monitoring VictoriaMetrics";
    homepage = "https://github.com/VictoriaMetrics/VictoriaMetrics/tree/master/dashboards";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
