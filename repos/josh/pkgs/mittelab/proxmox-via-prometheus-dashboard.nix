{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proxmox-via-prometheus-dashboard";
  version = "0-unstable-2023-04-25";

  src = fetchFromGitHub {
    owner = "mittelab";
    repo = "proxmox-via-prometheus-dashboard";
    rev = "c6fa49bb4e43486f1e267fc3812d0929155f67bd";
    hash = "sha256-FrjFIbFEhVyCBoK+KSNv8DQ6X7ddYXqSxThKX3df7dU=";
  };

  outputs = [
    "out"
    "prometheus"
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out $prometheus
    cp ./proxmox-via-prometheus.json $out/
    cp ./proxmox-via-prometheus.json $prometheus/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    json =
      runCommand "test-proxmox-via-prometheus-dashboard-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage} ${finalAttrs.finalPackage.prometheus} -name '*.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" >/dev/null
          touch $out
        '';
  };

  meta = {
    description = "Grafana Dashboard for Proxmox using Prometheus";
    homepage = "https://github.com/mittelab/proxmox-via-prometheus-dashboard";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
