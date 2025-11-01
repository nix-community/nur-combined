{
  config,
  lib,
  mkFormatterModule,
  pkgs,
  ...
}:
let
  cfg = config.programs.checkmake;
  ini = pkgs.formats.ini { };
in
{
  meta.maintainers = [
    lib.maintainers.wwmoraes
  ];

  imports = [
    (mkFormatterModule {
      name = "checkmake";
      package = "checkmake";
      args = [ ];
      includes = [
        "GNUmakefile"
        "Makefile"
      ];
    })
  ];

  options.programs.checkmake = {
    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = ini.type; };
      default = { };
      description = "Custom config file";
    };
    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable debug mode";
    };
  };

  config = lib.mkIf cfg.enable {
    settings.formatter.checkmake = {
      options =
        lib.optional (cfg.settings != { }) "--config=${ini.generate "checkmake.ini" cfg.settings}"
        ++ lib.optional cfg.debug "--debug";
    };
  };
}
