{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildGoModule rec {
  pname = "cheap-switch-exporter";
  version = "0-unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "pvelati";
    repo = "cheap-switch-exporter";
    rev = "57e3e3573ec06815218869e60d28290c6d14635b";
    hash = "sha256-w6XLxKgUT+G2EC7nb0OhMVRCFJccRPeMHY/fuRecCOk=";
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
