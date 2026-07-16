{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "victoria-logs-dashboards";
  version = "1.52.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaLogs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V4TWpv72LJ0FUYruwXvhmCpOLQh5l+7Of7aJS8vF6J0=";
  };

  outputs = [
    "out"
    "prometheus"
    "vm"
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out $prometheus $vm
    cp ./dashboards/*.json $out/
    cp ./dashboards/*.json $prometheus/
    cp ./dashboards/vm/*.json $vm/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "VictoriaLogs Grafana Dashboards";
    homepage = "https://github.com/VictoriaMetrics/VictoriaLogs/tree/main/dashboards";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
