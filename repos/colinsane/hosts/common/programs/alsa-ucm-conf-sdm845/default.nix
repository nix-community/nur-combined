{ pkgs, ... }:
{
  sane.programs.alsa-ucm-conf-sdm845 = {
    packageUnwrapped = pkgs.vanilla-mobile-nixos.pkgs.alsa-ucm-conf-sdm845.overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        # XXX(2026-08-28): jack detection is not working; disabling the JackControl should allow headphone paths to be manually selectable.
        sed -i '/JackControl "Headphone Jack"/d' \
          ucm2/Xiaomi/beryllium/HiFi.conf \
          ucm2/Xiaomi/beryllium/VoiceCall.conf

        # XXX(2026-08-28): jack detection is not working, so the profile would default to Speaker+Phone Mic.
        # instead, default it to Headset by decreasing Speaker/Phone-Bottom-Mic priority to be below Headphones/Headset-Mic priority.
        substituteInPlace ucm2/Xiaomi/beryllium/{HiFi.conf,VoiceCall.conf} \
          --replace-fail 'PlaybackPriority 100' 'PlaybackPriority 20' \
          --replace-fail 'CapturePriority 100' 'CapturePriority 20'

        # XXX(2026-08-28): headphones are quiet; make louder.
        # manually debug these with:
        # > amixer -c 0 scontrols | grep -Ei 'RX[12]|HP|headphone'
        # > amixer -c 0 cget name='RX1 Mix Digital Volume'
        # > amixer -c 0 cset name='RX1 Mix Digital Volume' 100
        substituteInPlace ucm2/Xiaomi/beryllium/beryllium.conf \
          --replace-fail 'cset "name='"'"'RX1 Digital Volume'"'"' 80"'   'cset "name='"'"'RX1 Mix Digital Volume'"'"' 100"' \
          --replace-fail 'cset "name='"'"'RX2 Digital Volume'"'"' 80"'   'cset "name='"'"'RX2 Mix Digital Volume'"'"' 100"'
      '';
    });
    sandbox.enable = false;  #< only provides /share/alsa
  };
}
