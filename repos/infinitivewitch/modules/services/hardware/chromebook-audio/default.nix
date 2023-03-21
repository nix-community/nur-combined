{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.hardware.chromebook-audio;
  eupnea-scripts = pkgs.fetchzip {
    url = "https://github.com/eupnea-linux/audio-scripts/archive/7999d1c4d43b798ed8db98d751536459d056d88f.zip";
    sha256 = "sha256-qzcnM6fBxOt1anZQ4Ot04VNb1Y9m0WzgBCp8SgT28Rw=";
  };
in
{
  options.services.hardware.chromebook-audio = with types; {
    enable = mkEnableOption "chromebook-audio";
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
      enableRedistributableFirmware = mkDefault true;
      firmware = with pkgs; [ alsa-firmware sof-firmware ];
    };

    environment.systemPackages = with pkgs; [
      alsa-lib
      alsa-utils
      alsa-ucm-conf
    ];

    boot.extraModprobeConfig = ''
      options snd-intel-dspcfg dsp_driver=3
      softdep snd_sof_pci_intel_icl pre: snd_hda_codec_hdmi
      softdep snd_sof_pci_intel_cnl pre: snd_hda_codec_hdmi
      softdep snd_sof_pci_intel_apl pre: snd_hda_codec_hdmi
      softdep snd_sof_pci_intel_tgl pre: snd_hda_codec_hdmi
      softdep snd_sof_pci_intel_tng pre: snd_hda_codec_hdmi
    '';

    system.replaceRuntimeDependencies = [
      {
        original = pkgs.alsa-ucm-conf;
        replacement = pkgs.alsa-ucm-conf.overrideAttrs (_super: {
          postFixup = ''
            cp -r ${eupnea-scripts}/configs/audio/sof/ucms/${cfg.board}/${cfg.card} $out/share/alsa/ucm2/conf.d/
            cp -r ${eupnea-scripts}/configs/audio/sof/ucms/dmic-common $out/share/alsa/ucm2/conf.d/
          '';
        });
      }
    ];
  };
}
