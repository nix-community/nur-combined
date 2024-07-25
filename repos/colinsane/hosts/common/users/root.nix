{ config, ... }:
{
  sane.persist.sys.byStore.ephemeral = [
    # when running commands as root, some things may create ~/.cache entries.
    # notably:
    # - `/root/.cache/nix/` takes up ~10 MB on lappy/desko/servo
    # - `/root/.cache/mesa_shader_cache` takes up 1-2 MB on moby
    # /root gets created earlier during boot, so safer to specify only subdirs here
    { path = "/root/.cache"; user = "root"; group = "root"; mode = "0700"; }
  ];
}
