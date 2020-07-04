{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nushell;

  # Convert a nix expression to a TOML file
  nixToTomlFile = name: expr:
    let json = pkgs.writeText "${name}-json" (builtins.toJSON expr);
    in pkgs.runCommand "${name}-toml" {} ''
      ${pkgs.remarshal}/bin/json2toml ${json} -o "$out"
    '';
in {
  options = {
    programs.nushell = {
      enable = lib.mkEnableOption "nushell";

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        example = lib.literalExample ''
          {
            completion_mode = "list";
            ctrlc_exit = true;
            edit_mode = "vi";
            key_timeout = 0;
            pivot_mode = "never";
          }
        '';
      };

      description = ''
        Configuration written to <filename>~/.config/nu/config.toml</filename>.
        See available options at <link>https://github.com/nushell/nushell/blob/master/docs/commands/config.md</link>
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nushell ];

    # We still make an empty file if settings is '{}', since nu tries to touch
    # the file, which would cause problems in the future
    home.file.".config/nu/config.toml".source = nixToTomlFile "nushell-config" cfg.settings;
  };
}
