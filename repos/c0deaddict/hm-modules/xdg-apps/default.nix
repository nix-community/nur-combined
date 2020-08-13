{ config, lib, pkgs, ... }:

with lib;

let

  appSubmodule = types.submodule {
    options = {
      name = mkOption { type = types.str; };

      package = mkOption { type = types.package; };

      mimeTypes = mkOption { type = with types; listOf str; };
    };
  };

  defaultApps = flip concatMap (attrValues config.xdg.apps)
    (app: map (m: "${m}=${app.name}.desktop") app.mimeTypes);

  mimeAppsList = pkgs.writeText "mimeapps.list" ''
    [Default Applications]
    ${(concatStringsSep "\n" defaultApps)}
  '';

  xdgApps = pkgs.runCommand "xdg_apps" { } ''
    mkdir -p $out/share/applications
    cp ${mimeAppsList} $out/share/applications/mimeapps.list
  '';

  xdgPackages = (map (getAttr "package") (attrValues config.xdg.apps));

in {

  options.xdg.apps = mkOption {
    default = { };
    type = with types; attrsOf appSubmodule;
    description = ''
      Configure XDG default apps for mime types.
    '';
  };

  config = mkIf (config.xdg.apps != { }) {
    home.packages = xdgPackages ++ [ xdgApps ];
  };

}
