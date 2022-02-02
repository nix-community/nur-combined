{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.pulseaudio;
  package = pkgs.nur.repos.dukzcry.pulseaudio;
  hfpscript = pkgs.writeShellScript "hfpscript" ''
    USER_NAME=$(w -hs | awk -v vt=tty$(fgconsole) '$0 ~ vt {print $1}')
    USER_ID=$(id -u "$USER_NAME")
    export PULSE_SERVER="unix:/run/user/"$USER_ID"/pulse/native"

    hdmi=$(sudo -u "$USER_NAME" LANG=C pactl --server "$PULSE_SERVER" list | grep "hdmi-stereo:" | grep -oE "available: no")

    for i in {1..3}; do
      sleep 1
      sudo -u "$USER_NAME" pactl --server "$PULSE_SERVER" set-card-profile bluez_card.41_42_BB_63_41_D9 handsfree_head_unit
      if [ "$?" = "0" ]; then
        break
      fi
    done
    sudo -u "$USER_NAME" pactl --server "$PULSE_SERVER" set-default-source bluez_source.41_42_BB_63_41_D9.handsfree_head_unit
    result=$?

    if [ "$hdmi" = "" ]; then
      profile="hdmi-stereo"
      sink=$profile
    else
      profile="analog-stereo"
      sink=$profile
    fi

    if [ "$result" = "1" ]; then
      profile=$profile"+input:analog-stereo"
    fi

    sudo -u "$USER_NAME" pactl --server "$PULSE_SERVER" set-card-profile alsa_card.pci-0000_00_1f.3 output:$profile
    sudo -u "$USER_NAME" pactl --server "$PULSE_SERVER" set-default-sink alsa_output.pci-0000_00_1f.3.$sink
  '';
in {
  options.programs.pulseaudio = {
    enable = mkEnableOption ''
      the PulseAudio sound server
    '';
  };

  config = mkIf cfg.enable {
    sound.enable = mkForce false;
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;
    programs.dconf.enable = true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol pulseeffects-legacy ];
    };
    # pactl list short modules
    #hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
      # 's/module-udev-detect$/module-udev-detect tsched=0/'
    #  sed 's/module-bluetooth-policy$/module-bluetooth-policy auto_switch=false/' \
    #    ${package}/etc/pulse/default.pa > $out
    #'';
    hardware.pulseaudio.package = package;
    systemd.services.hfp = {
      description = "HFP headset";
      path = with pkgs; [ procps gawk kbd coreutils sudo gnugrep package ];
      serviceConfig = {
        ExecStart = hfpscript;
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEM=="bluetooth", RUN+="${pkgs.systemd}/bin/systemctl start hfp.service"
    '';
  };
}
