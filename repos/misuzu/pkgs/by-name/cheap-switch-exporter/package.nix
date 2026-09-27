{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildGoModule rec {
  pname = "cheap-switch-exporter";
  version = "0-unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "pvelati";
    repo = "cheap-switch-exporter";
    rev = "40fead6d36ab7b588bbfaf6ee9206fd1e89db79c";
    hash = "sha256-RUn1s1SXdPoAA1m15MSAbR/7Jl2jzwagGz2ixQbkIMQ=";
  };

  vendorHash = "sha256-cOjGMHQXQwTY4Kp0Bw69BA1C9CmGfA/cn3+5HOhAhPc=";

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    inherit (src.meta) homepage;
    description = "Prometheus Exporter for cheap switch boxes without SNMP";
    mainProgram = "cheap-switch-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
  };
}
