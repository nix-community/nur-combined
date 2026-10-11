{ config, lib, pkgs, ... }:

let
  cfg = config.quriosity.programs.artcraft-suite;
  helpers = import ../lib/artcraft-suite.nix { inherit lib; };

  appPackage = id: pkgs.callPackage (../pkgs/apps/artcraft-suite + "/${id}") { };

  appRon = pkgs.writeText "artcraft-launcher-app.ron" (helpers.mkAppRon {
    inherit (cfg) theme language closeToTray;
  });

  autostartEntry = pkgs.writeText "ai.storyteller.artcraft-launcher.desktop" (helpers.mkAutostart cfg.package);

  stateDir = ".local/share/ai.storyteller.artcraft-launcher";
  autostartPath = ".config/autostart/ai.storyteller.artcraft-launcher.desktop";

  # Write the launcher's per-user state for `user`: a regular settings file the launcher can keep
  # writing to, and the autostart entry. A NixOS (re)build re-applies the declared choices.
  userScript = user:
    let
      u = config.users.users.${user};
      home = u.home or null;
    in
    lib.optionalString (home != null) ''
      if [ -d "${home}" ]; then
        install -d -m 0755 "${home}/${stateDir}"
        install -m 0644 -o "${user}" -g "${u.group}" ${appRon} "${home}/${stateDir}/app.ron"
      ${lib.optionalString cfg.autostart.enable ''
        install -d -m 0755 "${home}/.config/autostart"
        install -m 0644 -o "${user}" -g "${u.group}" ${autostartEntry} "${home}/${autostartPath}"
      ''}
      ${lib.optionalString (!cfg.autostart.enable) ''
        rm -f "${home}/${autostartPath}"
      ''}
      fi
    '';
in
{
  options.quriosity.programs.artcraft-suite = (helpers.mkOptions { inherit pkgs; }) // {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = map (u: u.name) (
        builtins.filter (u: u.isNormalUser or false) (builtins.attrValues config.users.users)
      );
      description = ''
        Users whose launcher settings and autostart entry are written. Defaults to every
        normal user. Set to `[ ]` to only install the packages system-wide.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ map appPackage cfg.packages;

    system.activationScripts.artcraft-suite = lib.concatMapStrings userScript cfg.users;
  };
}
