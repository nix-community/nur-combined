{ alsa-ucm-conf }:
alsa-ucm-conf.overrideAttrs (upstream: {
  # upstream alsa ships with PinePhone audio configs, but they don't actually produce sound.
  # see: <https://github.com/alsa-project/alsa-ucm-conf/pull/134>
  # these audio files come from some revision of:
  # - <https://gitlab.manjaro.org/manjaro-arm/packages/community/phosh/alsa-ucm-pinephone>
  #
  # alternative to patching is to plumb `ALSA_CONFIG_UCM2 = "${./ucm2}"` environment variable into the relevant places
  # e.g. `systemd.services.pulseaudio.environment`.
  # that leaves more opportunity for gaps (i.e. missing a service),
  # on the other hand this method causes about 500 packages to be rebuilt (including qt5 and webkitgtk).
  #
  # note that with these files, the following audio device support:
  # - headphones work.
  # - "internal earpiece" works.
  # - "internal speaker" doesn't work (but that's probably because i broke the ribbon cable)
  # - "analog output" doesn't work.
  postPatch = upstream.postPatch or "" + ''
    cp ${./ucm2/PinePhone}/* ucm2/Allwinner/A64/PinePhone/

    # fix the self-contained ucm files i source from to have correct path within the alsa-ucm-conf source tree
    substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
      --replace 'HiFi.conf' '/Allwinner/A64/PinePhone/HiFi.conf'
    substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
      --replace 'VoiceCall.conf' '/Allwinner/A64/PinePhone/VoiceCall.conf'

    # 2023/09/12: HARDWARE PATCH
    # - the internal speaker on my device is broken
    # - until i fix it, just make it a lower priority than the other devices
    #   so that it's never activated by default
    substituteInPlace ucm2/Allwinner/A64/PinePhone/* \
      --replace 'PlaybackPriority 300' 'PlaybackPriority 100'
  '';
})
