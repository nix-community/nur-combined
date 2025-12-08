# these audio files come from some revision of:
# - <https://gitlab.manjaro.org/manjaro-arm/packages/community/phosh/alsa-ucm-pinephone>
# note that with these files, the following audio device support:
# - headphones work.
# - "internal earpiece" works.
# - "internal speaker" doesn't work (but that's probably because i broke the ribbon cable)
# - "analog output" doesn't work.
{
  alsa-ucm-conf,
  lib,
  preferEarpiece ? false,
}:
alsa-ucm-conf.overrideAttrs (upstream: {
  postPatch = (upstream.postPatch or "") + ''
    cp ${./ucm2/PinePhone}/* ucm2/Allwinner/A64/PinePhone/

    # fix the self-contained ucm files i source from to have correct path within the alsa-ucm-conf source tree
    substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
      --replace-fail 'HiFi.conf' '/Allwinner/A64/PinePhone/HiFi.conf'
    substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
      --replace-fail 'VoiceCall.conf' '/Allwinner/A64/PinePhone/VoiceCall.conf'
  '' + lib.optionalString preferEarpiece ''
    # decrease the priority of the internal speaker so that sounds are routed
    # to the earpiece by default.
    # this is just personal preference.
    substituteInPlace ucm2/Allwinner/A64/PinePhone/{HiFi.conf,VoiceCall.conf} \
      --replace-fail 'PlaybackPriority 300' 'PlaybackPriority 100'
  '';
})
