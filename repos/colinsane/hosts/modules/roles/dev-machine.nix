{ config, lib, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.sane.roles.dev-machine;
in
{
  options.sane.roles.dev-machine = mkOption {
    type = types.bool;
    default = false;
    description = ''
      enable if this machine is used generally for "development"
      and you want tools to support that (e.g. docs).
    '';
  };

  config = mkMerge [
    ({
      sane.programs.docsets.config.rustPkgs = [
        "lemmy-server"
        "mx-sanebot"
      ];
    })
    (mkIf cfg {
      sane.programs.docsets.enableFor.system = true;
      # TODO: migrate this to `sane.user.programs.zeal.enable = true`
      sane.programs.zeal.enableFor.user.colin = true;
    })
  ];
}
