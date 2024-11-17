# dconf docs: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/profiles>
# this lets programs temporarily write user-level dconf settings (aka gsettings).
# they're written to ~/.config/dconf/user, unless `DCONF_PROFILE` is set to something other than the default of /etc/dconf/profile/user
# find keys/values with `dconf dump /`
{ config, lib, pkgs, ... }:

let
  # [ ProgramConfig ]
  enabledPrograms = builtins.filter
    (p: p.enabled && p.gsettings != {})
    (builtins.attrValues config.sane.programs);

  sitePackages = lib.map (p: pkgs.writeTextFile {
    name = "${p.name}-dconf";
    destination = "/etc/dconf/db/site.d/10_${p.name}";
    text = lib.generators.toDconfINI p.gsettings;
  }) enabledPrograms;

  profilePackage = pkgs.writeTextFile {
    name = "dconf-user-profile";
    destination = "/etc/dconf/profile/user";
    text = ''
      user-db:user
      system-db:site
    '';
  };

  cfg = config.sane.programs.dconf;
in
{
  sane.programs.dconf = {
    packageUnwrapped = pkgs.rmDbusServicesInPlace pkgs.dconf;
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
  };

  environment.etc.dconf = lib.mkIf cfg.enabled {
    source = pkgs.symlinkJoin {
      name = "dconf-system-config";
      paths = map (x: "${x}/etc/dconf") ([profilePackage] ++ sitePackages);
      nativeBuildInputs = [ (lib.getBin pkgs.dconf) ];
      postBuild = ''
        if test -d $out/db; then
          dconf update $out/db
        fi
      '';
    };
  };
}
