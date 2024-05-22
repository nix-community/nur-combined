
# Thanks to whoever originally wrote this battery_monitor script!
# (I forgot from whoom i copied it :upside_down:)
# has to be one of:
# - Julow: https://github.com/Julow/env/blob/0ea61eafa1c466997cf41406aea7be8a3a805429/modules/battery_monitor.nix
# - killercho: https://github.com/killercho/nixos-dotfiles/blob/70abcf71d7bb25b242093db6af74d30a18630ce5/scripts/battery_notifier.nix
# - viato115: https://github.com/viato115/nixos-conf/blob/84d3f419de51d7d4e80a736a4fcfe4b5988e25c6/modules/battery/battery_monitor.nix
# - modulitos: https://github.com/modulitos/dotfiles/blob/7fb71f0947b1e50060274a5ac72afa2f6a076939/.config/nixpkgs/modules/battery_monitor.nix
# - JucaRei: https://github.com/JucaRei/nixfiles/blob/916624808168883ac0f282403e593c5cf02db17c/home-manager/_mixins/desktop/hyprland/themes/my-theme/dunst.nix#L168
# definetly really cool, how it spread across github into so many nixos configs. also github's search for the win.
# and special thanks to aemogie for reminding me to thank the person i got it from, by starring the mize project :star_struck:
# https://github.com/aemogie/nivea/blob/9b662d6f1f6dfd350b3d1a9f8f7360a3cb520258/host/battery/monitor.nix

{ config, pkgs, lib, ... }:

# Regularly check the battery status and send a notification when it discharges
# below certain thresholds.
# Implemented by calling the `acpi` program regularly. This is the simpler and
# safer approach because the battery might not send discharging events.

let conf = config.modules.battery_monitor;

in {
  options.modules.battery_monitor = with lib; {
    enable = mkEnableOption "battery_monitor";
  };

  config = lib.mkIf conf.enable {
    # Regularly check battery status
    systemd.user.services.battery_monitor = {
      wants = [ "display-manager.service" ];
      wantedBy = [ "graphical-session.target" ];
      script = ''
		  count_10=0
        prev_val=100
        check () { [[ $1 -ge $val ]] && [[ $1 -lt $prev_val ]]; }
        notify () {
          ${pkgs.libnotify}/bin/notify-send -a Battery "$@" \
            -h "int:value:$val" "Discharging" "$val%, $remaining"
        }
        while true; do
          IFS=: read _ bat0 < <(${pkgs.acpi}/bin/acpi -b)
          IFS=\ , read status val remaining <<<"$bat0"
          val=''${val%\%}
          if [[ $status = Discharging ]]; then
            echo "$val%, $remaining"

            if check 20; then notify
            elif check 15 || [[ $val -le 7 ]]; then notify -u critical
				elif [[ $val -le 4 ]]
				then 
					${pkgs.notify}/bin/notify-send -a Hibernate soon...
					sleep 10
					${pkgs.notify}/bin/notify-send -a Hibernate NOW
					sudo systemctl hibernate
            fi
          fi
          prev_val=$val
          # Sleep longer when battery is high to save CPU
          if [[ $val -gt 30 ]]; then sleep 10m; elif [[ $val -ge 20 ]]; then sleep 5m; else sleep 1m; fi
        done
      '';
    };

  };
}
