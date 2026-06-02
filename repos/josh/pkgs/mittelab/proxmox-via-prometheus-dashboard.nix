{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
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

  meta = {
    description = "Grafana Dashboard for Proxmox using Prometheus";
    homepage = "https://github.com/mittelab/proxmox-via-prometheus-dashboard";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
