{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "alsa-ucm-pocophone";
  version = "0.1.0";
  src = ./src;

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/alsa
    cp -R $src $out/share/alsa/ucm2

    runHook postInstall
  '';

  meta = {
    description = "Alsa Use-Case-Manager (UCM) files for the Xiaomi Pocophone, based on <https://gitlab.com/sdm845-mainline/alsa-ucm-conf>";
    maintainers = [ lib.maintainers.colinsane ];
  };
}

# {
#   lib,
#   vanilla-mobile-nixos,
# }:
# vanilla-mobile-nixos.pkgs.alsa-ucm-conf-sdm845.overrideAttrs (prevAttrs: {
#   postPatch = (prevAttrs.postPatch or "") + ''
#     # XXX(2026-08-28): jack detection is not working; disabling the JackControl should allow headphone paths to be manually selectable.
#     sed -i '/JackControl "Headphone Jack"/d' \
#       ucm2/Xiaomi/beryllium/HiFi.conf \
#       ucm2/Xiaomi/beryllium/VoiceCall.conf
# 
#     # XXX(2026-08-28): jack detection is not working, so the profile would default to Speaker+Phone Mic.
#     # instead, default it to Headset by decreasing Speaker/Phone-Bottom-Mic priority to be below Headphones/Headset-Mic priority.
#     substituteInPlace ucm2/Xiaomi/beryllium/{HiFi.conf,VoiceCall.conf} \
#       --replace-fail 'PlaybackPriority 100' 'PlaybackPriority 20' \
#       --replace-fail 'CapturePriority 100' 'CapturePriority 20'
# 
#     # XXX(2026-08-28): headphones are quiet; make louder.
#     # manually debug these with:
#     # > amixer -c 0 scontrols | grep -Ei 'RX[12]|HP|headphone'
#     # > amixer -c 0 cget name='RX1 Mix Digital Volume'
#     # > amixer -c 0 cset name='RX1 Mix Digital Volume' 100
#     substituteInPlace ucm2/Xiaomi/beryllium/beryllium.conf \
#       --replace-fail 'cset "name='"'"'RX1 Digital Volume'"'"' 80"'   'cset "name='"'"'RX1 Mix Digital Volume'"'"' 100"' \
#       --replace-fail 'cset "name='"'"'RX2 Digital Volume'"'"' 80"'   'cset "name='"'"'RX2 Mix Digital Volume'"'"' 100"'
#   '';
# 
#   postInstall = ''
#     # we only want the pocophone bits -- avoid overriding any other alsa ucms
#     mkdir -p staging/share/alsa/ucm2/conf.d/sdm845 staging/share/alsa/ucm2/Xiaomi/beryllium
#     cp $out/share/alsa/ucm2/conf.d/sdm845/{xiaomi-XiaomiPocophoneF1Tianma.conf,'Xiaomi Poco F1.conf'} staging/share/alsa/ucm2/conf.d/sdm845
#     cp $out/share/alsa/ucm2/Xiaomi/beryllium/* staging/share/alsa/ucm2/Xiaomi/beryllium
#     rm -rf $out
#     mv staging $out
#   '';
# 
#   meta = (prevAttrs.meta) // {
#     platforms = lib.platforms.linux;
#   };
# })
