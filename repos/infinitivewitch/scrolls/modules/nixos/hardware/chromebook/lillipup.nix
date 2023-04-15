{
  config,
  lib,
  pkgs,
  ...
}: {
  sound.extraConfig = ''
    defaults.pcm.!card 1
    defaults.ctl.!card 1
  '';

  hardware.firmware = with pkgs; [sof-firmware];

  environment.systemPackages = with pkgs; [
    alsa-lib
    alsa-utils
    alsa-ucm-conf
  ];

  boot = {
    blacklistedKernelModules = ["snd_hda_intel" "snd_soc_skl"];
    extraModprobeConfig = "options snd-intel-dspcfg dsp_driver=3";
    kernelPackages = lib.mkDefault (pkgs.linuxPackagesFor pkgs.linux_latest);
  };
}
