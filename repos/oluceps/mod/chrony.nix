{
  flake.modules.nixos.chrony = {
    services = {

      # bpftune.enable = true;
      chrony = {
        enable = true;
        extraConfig = ''
          makestep 1.0 3
        '';
      };
    };
  };
}
