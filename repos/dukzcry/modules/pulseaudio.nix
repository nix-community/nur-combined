{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.pulseaudio;
  audio = pkgs.writeShellScript "audio" ''
    USER_NAME=$(w -hs | awk -v vt=tty$(fgconsole) '$0 ~ vt {print $1}')
    USER_ID=$(id -u "$USER_NAME")
    export PULSE_SERVER="unix:/run/user/"$USER_ID"/pulse/native"

    hdmi=$(sudo -u "$USER_NAME" LANG=C pactl --server "$PULSE_SERVER" list | grep "hdmi-stereo:" | grep -oE "available: no")

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
    #hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
    #  sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
    #    ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    #'';
    hardware.pulseaudio.package = pkgs.nur.repos.dukzcry.pulseaudio;
    systemd.services.hfpmic = {
      description = "HFP microphone";
      path = with pkgs; [ procps gawk kbd coreutils sudo gnugrep pkgs.nur.repos.dukzcry.pulseaudio ];
      serviceConfig = {
        ExecStart = audio;
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEM=="bluetooth", RUN+="${pkgs.systemd}/bin/systemctl start hfpmic.service"
    '';
  };
}
