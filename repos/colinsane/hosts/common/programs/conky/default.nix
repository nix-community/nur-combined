{ pkgs, ... }:
{
  sane.programs.conky = {
    # TODO: non-sandboxed `conky` still ships via `sxmo-utils`, but unused
    sandbox.method = "bwrap";
    sandbox.net = "clearnet";  #< for the scripts it calls (weather)
    sandbox.extraPaths = [
      "/sys/class/power_supply"
      "/sys/devices"  # needed by battery_estimate
      # "/sys/devices/cpu"
      # "/sys/devices/system"
    ];
    sandbox.whitelistWayland = true;

    fs.".config/conky/conky.conf".symlink.target =
      let
        # TODO: make this just another `suggestedPrograms`!
        battery_estimate = pkgs.static-nix-shell.mkBash {
          pname = "battery_estimate";
          srcRoot = ./.;
        };
      in pkgs.substituteAll {
        src = ./conky.conf;
        bat = "${battery_estimate}/bin/battery_estimate";
        weather = "timeout 20 ${pkgs.sane-weather}/bin/sane-weather";
      };

    services.conky = {
      description = "conky dynamic desktop background";
      partOf = [ "graphical-session" ];
      command = "conky";
    };
  };
}
