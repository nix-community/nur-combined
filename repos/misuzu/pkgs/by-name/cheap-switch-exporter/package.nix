{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "cheap-switch-exporter";
  version = "0-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "pvelati";
    repo = "cheap-switch-exporter";
    rev = "6fc170d3b82677d3b084501876950d7c97e26981";
    hash = "sha256-VERzJdbyb1zPBMdhXreSNvvAUVEi4zcFyPMY4n8OtHw=";
  };

  vendorHash = "sha256-lDkFfGcP9iqGyQzXtUiNV9vsqWE0CzaGHEn5YQRC99o=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    inherit (src.meta) homepage;
    description = "Prometheus Exporter for cheap switch boxes without SNMP";
    mainProgram = "cheap-switch-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
  };
}
