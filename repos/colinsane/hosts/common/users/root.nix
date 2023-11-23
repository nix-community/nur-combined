{ config, ... }:
{
  sane.persist.sys.byStore.cryptClearOnBoot = [
    # when running commands as root, some things may create ~/.cache entries.
    # notably:
    # - `/root/.cache/nix/` takes up ~10 MB on lappy/desko/servo
    # - `/root/.cache/mesa_shader_cache` takes up 1-2 MB on moby
    { path = "/root"; user = "root"; group = "root"; mode = "0700"; }
  ];
}
