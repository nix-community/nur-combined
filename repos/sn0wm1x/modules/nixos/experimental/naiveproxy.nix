{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.naiveproxy;
  format = pkgs.formats.json { };
  pkg = pkgs.callPackage ../../pkgs/by-name/naiveproxy-bin.nix;
in
{
  meta.maintainers = pkg.meta.maintainers;

  options.services.naiveproxy = {
    enable = lib.mkEnableOption pkg.meta.description;

    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      defaultText = "pkgs.naiveproxy-bin";
    };

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          listen = lib.mkOption {
            type = lib.types.str;
            default = "socks://127.0.0.1:1080";
          };

          proxy = lib.mkOption {
            type = lib.types.str;
          };

          log = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.naiveproxy = {
      description = pkg.meta.description;
      documentation = [ pkg.meta.homepage ];

      after = [ "network-online.target" ];

      preStart = ''
        umask 0077
        ${utils.genJqSecretsReplacementSnippet cfg.settings "/run/naiveproxy/config.json"}
      '';

      serviceConfig = {
        DynamicUsers = true;
        ExecStart = "${lib.getExe cfg.package} /run/naiveproxy/config.json";
        Restart = "on-failure";
        RuntimeDirectory = "naiveproxy";
      };
    };
  };
}
