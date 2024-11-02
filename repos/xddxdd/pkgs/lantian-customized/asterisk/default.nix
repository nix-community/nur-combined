{
  lib,
  sources,
  callPackage,
  asterisk_20,
  asteriskDigiumCodecs,
  asterisk-g72x,
  opencore-amr,
  spandsp3,
  codec2,
  libvorbis,
  vo-amrwbenc,
}:
let
  asterisk-actual = asterisk_20;
  codecs-actual = asteriskDigiumCodecs."20";
  asterisk-g72x-actual = asterisk-g72x.override { asterisk = asterisk-actual; };
  _3gpp-evs = callPackage ./3gpp-evs.nix { };

  # Patches that use patch -p0
  myPatches = [
    "${sources.asterisk-amr.src}/codec_amr.patch"
    "${sources.asterisk-amr.src}/build_tools.patch"
    ./codec_evs.patch
    "${sources.asterisk-evs.src}/build_evs.patch"
    "${sources.asterisk-evs.src}/force_limitations.patch"
    "${sources.asterisk-gsm-efr.src}/codec_gsm_efr.patch"
  ];

  myExtraFiles = [
    # sources.asterisk-alaw16.src
    sources.asterisk-amr.src
    sources.asterisk-evs.src
    sources.asterisk-gsm-efr.src
  ];
in
(asterisk-actual.override { withOpus = false; }).overrideAttrs (old: {
  prePatch =
    (lib.concatStrings (builtins.map (p: "cp -r ${p}/* ./\n") myExtraFiles)) + (old.prePatch or "");

  postPatch =
    (lib.concatStrings (builtins.map (p: "echo ${p}; patch -p0 < ${p}\n") myPatches))
    + (old.postPatch or "");

  # Patches that use patch -p1
  patches = [
    ./mp3player-use-ffmpeg.patch
  ];

  preConfigure =
    ''
      cp ${./pjsip-disable-sips-check.patch} ./third-party/pjproject/patches/pjsip-disable-sips-check.patch
    ''
    + (old.preConfigure or "");

  buildInputs = (old.buildInputs or [ ]) ++ [
    _3gpp-evs
    opencore-amr
    codec2
    libvorbis
    spandsp3
    vo-amrwbenc
  ];

  preBuild =
    (old.preBuild or "")
    + ''
      sed -i "s/MENUSELECT_ADDONS=.*/MENUSELECT_ADDONS=chan_mobile res_config_mysql/" menuselect.makeopts
      export MAKEFLAGS=-j$(nproc)
    '';

  postInstall =
    (old.postInstall or "")
    + ''
      ln -s ${codecs-actual.opus}/codec_opus.so $out/lib/asterisk/modules/codec_opus.so
      ln -s ${codecs-actual.opus}/format_ogg_opus.so $out/lib/asterisk/modules/format_ogg_opus.so
      ln -s ${codecs-actual.opus}/codec_opus_config-en_US.xml $out/var/lib/asterisk/documentation/thirdparty/codec_opus_config-en_US.xml
      ln -s ${codecs-actual.silk}/codec_silk.so $out/lib/asterisk/modules/codec_silk.so
      ln -s ${codecs-actual.siren7}/codec_siren7.so $out/lib/asterisk/modules/codec_siren7.so
      ln -s ${codecs-actual.siren14}/codec_siren14.so $out/lib/asterisk/modules/codec_siren14.so
      ln -s ${asterisk-g72x-actual}/lib/asterisk/modules/codec_g729.so $out/lib/asterisk/modules/codec_g729.so
    '';

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Asterisk with Lan Tian modifications";
    platforms = [ "x86_64-linux" ];
  };
})
