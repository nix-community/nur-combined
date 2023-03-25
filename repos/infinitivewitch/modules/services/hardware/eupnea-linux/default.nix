{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.hardware.eupnea-linux;
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
in
{
  options.services.hardware.eupnea-linux = with types; {
    enable = mkEnableOption "eupnea-linux";
    board = mkOption {
      type = str;
      default = "tgl";
      description = "Device board type";
    };
    card = mkOption {
      type = str;
      default = "sof-rt5682";
      description = "Sound card name";
    };
  };

  config = mkIf cfg.enable {
    boot.blacklistedKernelModules = [ "snd_hda_intel" "snd_soc_skl" ];

    boot.kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linux_latest);

    sound.extraConfig = ''
      defaults.pcm.!card 1
      defaults.ctl.!card 1
    '';

    hardware = {
      firmware = with pkgs; [ sof-firmware ];
      enableRedistributableFirmware = mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      alsa-lib
      alsa-utils
      alsa-ucm-conf
    ];

    boot.extraModprobeConfig = ''
      options snd-intel-dspcfg dsp_driver=3
    '';

    system.replaceRuntimeDependencies = [
      {
        original = pkgs.alsa-ucm-conf;
        replacement = pkgs.alsa-ucm-conf.overrideAttrs (_super: {
          postFixup = with nur.repos.infinitivewitch; ''
            cp -r ${audio-scripts}/configs/audio/sof/ucms/${cfg.board}/${cfg.card} $out/share/alsa/ucm2/conf.d/
            cp -r ${audio-scripts}/configs/audio/sof/ucms/dmic-common $out/share/alsa/ucm2/conf.d/
            cp -r ${audio-scripts}/configs/audio/sof/ucms/hdmi-common $out/share/alsa/ucm2/conf.d/
          '';
        });
      }
    ];
  };
}
