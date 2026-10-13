# Ported to nix-darwin from the NixOS nh module:
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/nh.nix
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.programs.nh;
in
{
  options.programs.nh = {
    enable = lib.mkEnableOption "nh, a Nix CLI helper";

    package = lib.mkPackageOption pkgs "nh" { };

    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/Users/alice/nix-config";
      description = ''
        Default flake reference exported as NH_FLAKE when nh is enabled.
        NH_DARWIN_FLAKE and NH_HOME_FLAKE override it for their commands.
      '';
    };

    clean = {
      enable = lib.mkEnableOption "scheduled garbage collection with nh clean all";

      interval = lib.mkOption {
        type = options.nix.gc.interval.type;
        default = [
          {
            Weekday = 7;
            Hour = 3;
            Minute = 15;
          }
        ];
        example = [
          {
            Hour = 23;
            Minute = 0;
          }
        ];
        description = ''
          launchd StartCalendarInterval schedule for cleanup, in local time.
          Unlike NixOS clean.dates, this uses calendar attributes, not systemd syntax.
        '';
      };

      extraArgs = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "--no-direnv";
        example = "--no-direnv --keep 3 --keep-since 7d";
        description = ''
          Shell arguments appended to nh clean all. The default preserves direnv
          GC roots. These arguments run as root; use only trusted configuration.
        '';
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.flake == null || !(lib.hasSuffix ".nix" cfg.flake);
        message = "programs.nh.flake must be a flake reference or directory, not a Nix file.";
      }
      {
        assertion = !(cfg.clean.enable && config.nix.gc.automatic);
        message = "Enable either programs.nh.clean.enable or nix.gc.automatic, not both.";
      }
    ];

    environment = lib.mkIf cfg.enable {
      systemPackages = [ cfg.package ];
      variables = lib.mkIf (cfg.flake != null) {
        NH_FLAKE = cfg.flake;
      };
    };

    launchd.daemons.nh-clean = lib.mkIf cfg.clean.enable {
      command = "${lib.escapeShellArg (lib.getExe cfg.package)} clean all ${cfg.clean.extraArgs}";
      path = [
        config.nix.package
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
      serviceConfig = {
        UserName = "root";
        RunAtLoad = false;
        StartCalendarInterval = cfg.clean.interval;
      };
    };
  };
}
