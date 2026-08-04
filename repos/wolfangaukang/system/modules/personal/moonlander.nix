{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.profile.moonlander;

in
{
  options.profile.moonlander = {
    enable = mkEnableOption "Moonlander Mark I support on NixOS";
    ignoreLayoutSettings = mkEnableOption "Ignore any system layout settings (uses US Basic)";
    extraPkgs = lib.mkOption {
      default = with pkgs; [ wally-cli ];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = cfg.extraPkgs;
      hardware.keyboard.zsa.enable = true;
      services.xserver.extraConfig = mkIf cfg.ignoreLayoutSettings ''${builtins.readFile "${inputs.dotfiles}/config/xorg/99-moonlander.conf"}'';
    }
  ]);
}
