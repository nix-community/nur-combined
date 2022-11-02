{ config, lib, ... }:

with lib;

{
  options = {
    home.defaultShell = mkOption
      {
        type = with types; nullOr package;
        default = null;
        example = literalExpression "pkgs.fish";
      };
  };
  config = {
    home.activation.chsh =
      let
        shell = config.home.defaultShell;
        username = config.home.username;
      in
      (mkIf (shell != null) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Set default shell.
        echo "setting default shell..." >&2

        $DRY_RUN_CMD sudo chsh -s ${getExe shell} ${username}
      ''));
  };
}
