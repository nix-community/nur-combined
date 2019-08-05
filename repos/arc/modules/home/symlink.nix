{ lib, config, ... }: with lib; let
  cfg = config.home.symlink;
  symlinkType = types.submodule {
    options = {
      target = mkOption {
        type = types.str;
      };
      create = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  activationScript = concatStringsSep "\n" (mapAttrsToList activationScript' cfg);
  activationScript' = name: link: ''
    $DRY_RUN_CMD mkdir -p $(dirname ~/${name})
    $DRY_RUN_CMD ln -nsf ${link.target} ~/${name}
    ${if link.create then activationMkdir name link else ""}
  '';
  activationMkdir = name: link: ''
    LINK_TARGET_DIR=${link.target}
    if [[ $LINK_TARGET_DIR = /* ]]; then
      $DRY_RUN_CMD mkdir -p ''${LINK_TARGET_DIR%/*}
    else
      $DRY_RUN_CMD mkdir -p ~/$(dirname ${name})/''${LINK_TARGET_DIR%/*}
    fi
  '';
in {
  options = {
    home.symlink = mkOption {
      type = types.attrsOf symlinkType;
      default = { };
    };
  };

  config.home.activation = mkIf (cfg != { }) {
    symlink = config.lib.dag.entryAfter ["writeBoundary"] activationScript;
  };
}
