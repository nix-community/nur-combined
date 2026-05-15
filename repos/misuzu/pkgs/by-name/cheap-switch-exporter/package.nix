{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildGoModule rec {
  pname = "cheap-switch-exporter";
  version = "0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "pvelati";
    repo = "cheap-switch-exporter";
    rev = "2a0e07a11b1f0244c9d993b413f411e5acbc0696";
    hash = "sha256-08A/LUsX0HTCcy8WaXo4aXIlAs4dxl8PONUCx87JVmw=";
  };

  vendorHash = "sha256-U6ue3roBFYQOLaKnJ3uodnL30pc5JEBy5tmK3F4IIc8=";

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    inherit (src.meta) homepage;
    description = "Prometheus Exporter for cheap switch boxes without SNMP";
    mainProgram = "cheap-switch-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
  };
}
