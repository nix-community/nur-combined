{
  lib,
  nixosTest,
  tinyfeed,
}:

nixosTest (_: {
  name = "tinyfeed";

  meta.maintainers = [ lib.maintainers.federicoschonborn ];

  nodes.machine = {
    imports = [
      ../../../modules/nixos/tinyfeed.nix
    ];

    services.tinyfeed = {
      enable = true;
      package = tinyfeed;
    };
  };

  testScript = ''
    machine.wait_for_unit("tinyfeed.service")
  '';
})
