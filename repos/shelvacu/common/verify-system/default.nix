{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.vacu.verifySystem;
in
{
  imports = [ ./nixos.nix ];
  options.vacu.verifySystem = {
    enable = (mkEnableOption "verify system is what is expected") // {
      default = false;
    };
    verifiers = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              enable = mkEnableOption "Enable system ident check ${name}";
              name = mkOption {
                type = types.str;
                default = name;
              };
              script = mkOption {
                type = types.lines;
                default = "## system ident check ${config.name}";
                defaultText = lib.literalText ''## system ident check ${name}'';
              };
            };
          }
        )
      );
    };

    verifyAllScript =
      let
        verifiers = (builtins.attrValues cfg.verifiers);
        enabled = builtins.filter (s: s.enable) verifiers;
        files = map (s: pkgs.writeText "vacu-verify-system-${s.name}.sh" s.script) enabled;
        script = ''
          ## vacu verify-system
          for f in ${lib.escapeShellArgs files}; do
            echo "verifying system with $f"
            if ! source "$f"; then
              echo "ERR: $f failed" >&2
              return 1
            fi
          done
        '';
        scriptFile = pkgs.writeText "vacu-verify-system-all.sh" script;
      in
      mkOption {
        readOnly = true;
        default = scriptFile;
        defaultText = "vacu-verify-system-all.sh package";
      };
  };
}
