{
  nixosInstaller,
  linkFarm,
  writers,
  pixiecore,
  lib,
}:
let
  build = nixosInstaller.config.system.build;
  script = writers.writeBashBin "host-pixie-installer" { } ''
    set -euo pipefail
    exec ${lib.getExe pixiecore} boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd "$@"
  '';
in
(linkFarm "host-pixie-installer" {
  "bin/host-pixie-installer" = "${script}/bin/host-pixie-installer";
  inherit (build) kernel netbootRamdisk;
}).overrideAttrs
  (old: {
    meta = {
      mainProgram = "host-pixie-installer";
    };
  })
