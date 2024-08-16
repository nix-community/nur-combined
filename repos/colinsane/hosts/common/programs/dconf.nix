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
    configOption = with lib; mkOption {
      type = types.submodule {
        options = {
          site = mkOption {
            type = types.listOf types.package;
            default = [];
            description = ''
              extra packages to link into /etc/dconf
            '';
          };
        };
      };
      default = {};
    };

    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.dconf;
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "user" ];
    persist.byStore.private = [
      ".config/dconf"
    ];

    services.dconf = {
      description = "dconf configuration database/server";
      partOf = [ "default" ];
      command = "${lib.getLib cfg.package}/libexec/dconf-service";
    };

    # supposedly necessary for packages which haven't been wrapped (i.e. wrapGtkApp?),
    # but in practice seems unnecessary.
    # env.GIO_EXTRA_MODULES = "${pkgs.dconf.lib}/lib/gio/modules";

    config.site = [
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

  # TODO: get dconf to read these from ~/.config/dconf ?
  environment.etc.dconf = lib.mkIf cfg.enabled {
    source = pkgs.symlinkJoin {
      name = "dconf-system-config";
      paths = map (x: "${x}/etc/dconf") cfg.config.site;
      nativeBuildInputs = [ (lib.getBin pkgs.dconf) ];
      postBuild = ''
        if test -d $out/db; then
          dconf update $out/db
        fi
      '';
    };
  };
}
