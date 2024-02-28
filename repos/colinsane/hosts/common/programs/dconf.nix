# dconf docs: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/profiles>
# this lets programs temporarily write user-level dconf settings (aka gsettings).
# they're written to ~/.config/dconf/user, unless `DCONF_PROFILE` is set to something other than the default of /etc/dconf/profile/user
# find keys/values with `dconf dump /`
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.programs.dconf;
in
{
  sane.programs.dconf = {
    sandbox.method = "bwrap";
    persist.byStore.private = [
      ".config/dconf"
    ];
  };

  programs.dconf = lib.mkIf cfg.enabled {
    # note that `programs.dconf` doesn't allow specifying the dconf package.
    enable = true;
    packages = [
      (pkgs.writeTextFile {
        name = "dconf-user-profile";
        destination = "/etc/dconf/profile/user";
        text = ''
          user-db:user
          system-db:site
        '';
      })
    ];
  };
}
