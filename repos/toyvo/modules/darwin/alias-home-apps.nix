{
  config,
  home-manager,
  lib,
  pkgs,
  ...
}:
let
  mkalias = pkgs.callPackage ../../pkgs/mkalias {};
  cfg = config.targets.darwin;
  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
    pathsToLink = "/Applications";
  };
in
{
  options.targets.darwin.aliasHomeApplications = lib.mkEnableOption "Alias Home Manager Applications in ~/Applications/Home Manager Apps";

  config = lib.mkIf cfg.aliasHomeApplications {
    home.file."Applications/Home Manager Apps".enable = false;
    home.activation.aliasApplications = home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.coreutils}/bin/echo "setting up ~/Applications/Home Manager Apps..." >&2
      app_path="$HOME/Applications/Home Manager Apps"
      tmp_path=$(${pkgs.coreutils}/bin/mktemp -dt "home-manager-applications.XXXXXX") || exit 1
      if [[ -d "$app_path" ]]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf "$app_path"
      fi
      $DRY_RUN_CMD ${lib.getExe pkgs.fd} -t l -d 1 . ${apps}/Applications -x ${lib.getExe mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmp_path" "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod -R 775 "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chgrp -R staff "$app_path"
    '';
  };
}
