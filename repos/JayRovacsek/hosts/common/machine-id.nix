{ config, ... }:
let
  machineIdFunction = import ../../functions/machine-id.nix;
  # The below is utilised to ensure our host has it's machine-id
  # file written consistently as per: https://astro.github.io/microvm.nix/faq.html#how-to-centralize-logging-with-journald
in {
  systemd.machineId =
    machineIdFunction { inherit (config.networking) hostName; };

  environment.etc."machine-id" = {
    mode = "0644";
    text = ''
      ${config.systemd.machineId}
    '';
  };
}
