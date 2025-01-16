{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.pulseaudio;
  pulseaudio = pkgs.pulseaudioFull.overrideAttrs (oldAttrs: optionalAttrs cfg.bluetoothMic {
    preConfigure = ''
      # Disable PA_BLUETOOTH_UUID_A2DP_SINK
      #substituteInPlace src/modules/bluetooth/bluez5-util.h \
      #  --replace-fail "0000110b-0000-1000-8000-00805f9b34fb" "0000110b-0000-1000-8000-00805f9b34fc"
      # Disable output for PA_BLUETOOTH_PROFILE_HFP_HF
      substituteInPlace src/modules/bluetooth/module-bluez5-device.c \
        --replace-fail "[PA_BLUETOOTH_PROFILE_HFP_HF] = PA_DIRECTION_INPUT | PA_DIRECTION_OUTPUT" "[PA_BLUETOOTH_PROFILE_HFP_HF] = PA_DIRECTION_INPUT"
    '';
  });
in {
  options.programs.pulseaudio = {
    enable = mkEnableOption ''
      the PulseAudio sound server
    '';
    bluetoothMic = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Prevent output to bluetooth headphones, converting them into bluetooth microphone
      '';
    };
  };

  config = mkIf cfg.enable {
    sound.enable = mkForce false;
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;
    programs.dconf.enable = mkDefault true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol ];
    };
    # pactl list short modules
    #hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
    #  sed -e 's/module-udev-detect$/module-udev-detect tsched=0/' \
    #    ${package}/etc/pulse/default.pa > $out
    #'';
    hardware.pulseaudio.package = pulseaudio;
  };
}
