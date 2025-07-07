{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf singleton;
  cfg = config.abszero.services.pipewire;
in

{
  options.abszero.services.pipewire.enable = mkEnableOption "PipeWire multimedia framework";

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # Extreme values taken from https://github.com/NixOS/nixpkgs/blob/29e290002bfff26af1db6f64d070698019460302/nixos/modules/services/desktops/pipewire/pipewire.nix#L419
      extraConfig.pipewire."20-module-rt"."context.modules" = singleton {
        name = "libpipewire-module-rt";
        args = {
          "nice.level" = -19;
          "rt.prio" = 95;
        };
      };
    };
  };
}
