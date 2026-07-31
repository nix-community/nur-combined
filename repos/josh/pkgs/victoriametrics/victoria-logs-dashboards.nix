{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "victoria-logs-dashboards";
  version = "1.52.0";

  outputs = [
    "out"
    "prometheus"
    "vm"
  ];

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaLogs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V4TWpv72LJ0FUYruwXvhmCpOLQh5l+7Of7aJS8vF6J0=";
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

  # The repo inherited the full VictoriaMetrics tag history when it was split
  # out, so tag-based discovery can jump to old VictoriaMetrics versions above
  # this pin; the releases API contains only VictoriaLogs' own releases
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--use-github-releases"
    ];
  };

  passthru.tests = {
    json =
      runCommand "test-victoria-logs-dashboards-json"
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
    description = "Grafana dashboards for monitoring VictoriaLogs";
    homepage = "https://github.com/VictoriaMetrics/VictoriaLogs/tree/master/dashboards";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
