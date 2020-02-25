{ config, lib, pkgs, ... } @ args:

let

  trace = args.trace or
    # builtins.trace;
    (_: x: x);
  traceVal = args.traceVal or
    # lib.traceVal;
    (_: x: x);

  cfg = config.programs.pijul;

  # By default, located at (you probably want to set $XDG_DATA_HOME):
  # 1) $PIJUL_CONFIG_DIR/config.toml
  # 2) $XDG_DATA_HOME/pijul/config/config.toml
  # 3) ~/.pijulconfig/config.toml
  globalCfgMod = let
    inherit (lib) types;
    inherit (types) mkOption nullOr;
  in trace "globalCfgMod" {
    options = trace "globalCfgMod.options" {
      author = mkOption {
        default = trace "global.author default" null;
        description = "Default author to use.";
        example = "me <me@example.com>";
        type = trace "global.author" (nullOr types.str);
      };
      editor = mkOption {
        default = trace "global.editor default" (traceVal "${traceVal config.home.sessionVariables.VISUAL}");
        defaultText = traceVal "\"\${config.home.sessionVariables.VISUAL}\"";
        description = "Default editor to use.";
        example = traceVal "nvim";
        type = trace "global.editor" (nullOr types.str);
      };
      signing_key = mkOption {
        default = trace "global.signing_key default" null;
        description = ''
          Absolute path to your signing secret key.

          A signing key can be generated with <code>pijul key gen --signing-id
          'me@example.com'</code>, and will by default be placed in your Pijul
          global config directory.
        '';
        example = traceVal
          "\"\${config.xdg.dataHome}/pijul/config/signing_secret_key\"";
        type = trace "global.signing_key" (nullOr types.str);
      };
      extraConfig = mkOption {
        default = trace "global.extraConfig default" null;
        description = ''
          Extra lines to be added verbatim to the
          <filename>config.toml</filename> configuration file.
        '';
        type = trace "global.extraConfig" (nullOr types.lines);
      };
    };
  };

in

{
  meta.maintainers = [ lib.maintainers.bb010g ];

  options = let
    inherit (lib) mkEnableOption mkOption types;
    inherit (types) nullOr submodule;
  in {
    programs.pijul = trace "options programs.pijul" {
      enable = trace "pijul.enable" (mkEnableOption "Pijul");

      package = trace "pijul.package" (mkOption {
        default = traceVal pkgs.pijul;
        defaultText = traceVal "pkgs.pijul";
        description = "Pijul package to install.";
        type = types.package;
      });

      global = trace "pijul.global" (submodule (trace "pijul.global submodule" globalCfgMod));

      configDir = trace "pijul.configDir" (mkOption {
        default = "${config.xdg.configHome}/pijul";
        defaultText = "$XDG_CONFIG_HOME/pijul";
        description = "Pijul config directory path.";
        type = types.str;
      });
    };
  };

  config = lib.mkIf cfg.enable (trace "config programs/pijul" {
    home.packages = trace "pijul home.packages" [ cfg.package ];

    home.sessionVariables.PIJUL_CONFIG_DIR = trace "pijul home.sessionVariables.PIJUL_CONFIG_DIR" cfg.configDir;

    # should really be toTOML
    home.file."${cfg.configDir}/config.toml".text = trace "home.file.$PIJUL_CONFIG.text" (let
      global = trace "pijul cfg.global" cfg.global;
      genConfig = trace "genConfig" (lib.generators.toKeyValue { } {
        inherit (global) author editor signing_key;
      });
      extraConfig = trace "extraConfig" global.extraConfig;
      configs = trace "configs" ([ genConfig ] ++
        lib.optional (extraConfig != null) extraConfig);
    in trace "pijul config.toml" (lib.concatStringsSep "\n" configs));
  });
}
