{ pkgs, ... }:
{
  sane.programs.alsa-ucm-conf-sdm845 = {
    packageUnwrapped = pkgs.vanilla-mobile-nixos.pkgs.alsa-ucm-conf-sdm845.overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        substituteInPlace ucm2/Xiaomi/beryllium/HiFi.conf \
          --replace-fail "TAS2559 DAC Playback Volume' 35" "TAS2559 DAC Playback Volume' 15"
      '';
    });
    sandbox.enable = false;  #< only provides /share/alsa
  };
}
