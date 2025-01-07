{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkalias = pkgs.callPackage ../../pkgs/mkalias {};
  cfg = config.system.defaults.finder;
  apps = config.system.build.applications;
in
{
  options.system.defaults.finder.AliasSystemApplications = lib.mkEnableOption "Alias system applications";

  config = lib.mkIf cfg.AliasSystemApplications {
    system.activationScripts.applications.text = lib.mkForce ''
      ${pkgs.coreutils}/bin/echo "setting up /Applications/Nix Apps..." >&2
      app_path="/Applications/Nix Apps"
      tmp_path=$(${pkgs.coreutils}/bin/mktemp -dt "nix-darwin-applications.XXXXXX") || exit 1
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
