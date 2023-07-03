{ config, lib, pkgs, inputs, ... }:

let
  work_config = config.profile.specialisations.work.simplerisk;
  sway_config = config.programs.sway;
  inherit (inputs) self;

in {
  programs.fish.enable = true;
  users.users.bjorn = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "nixers" ];
  };
  # TODO: Fix this integration // lib.optionals (sway_config.enable) (import "${self}/home/profiles/programs/sway.nix" { inherit config lib pkgs; });
}
