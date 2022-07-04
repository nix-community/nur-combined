{ lib
, sources
, callPackage
, asterisk
, asteriskDigiumCodecs
, asterisk-g72x
, fetchFromGitHub
, opencore-amr
, codec2
, libvorbis
, vo-amrwbenc
, ...
} @ args:

let
  _3gpp-evs = callPackage ./3gpp-evs.nix { };
in
(asterisk.override { withOpus = false; }).overrideAttrs (old: {
  inherit (sources.asterisk) pname version src;

  patches = (old.patches or [ ]) ++ [
    ./alaw16_pass_through.patch
  ];

  prePatch = ''
    cp -r ${sources.asterisk-alaw16.src}/* ./
    cp -r ${sources.asterisk-amr.src}/* ./
    cp -r ${sources.asterisk-evs.src}/* ./
    cp -r ${sources.asterisk-gsm-efr.src}/* ./
  '' + (old.prePatch or "");

  postPatch =
    let
      myPatches = [
        "${sources.asterisk-alaw16.src}/alaw16_transcoding.patch"
        "${sources.asterisk-amr.src}/codec_amr.patch"
        "${sources.asterisk-amr.src}/build_tools.patch"
        ./codec_evs.patch
        "${sources.asterisk-evs.src}/build_evs.patch"
        "${sources.asterisk-evs.src}/force_limitations.patch"
        "${sources.asterisk-gsm-efr.src}/codec_gsm_efr.patch"
      ];
    in
    (builtins.concatStringsSep "\n" (builtins.map
      (p: ''
        echo ${p}
        patch -p0 < ${p}
      '')
      myPatches)) + (old.postPatch or "");

  buildInputs = (old.buildInputs or [ ]) ++ [
    _3gpp-evs
    opencore-amr
    codec2
    libvorbis
    vo-amrwbenc
  ];

  preBuild = (old.preBuild or "") + ''
    substituteInPlace menuselect.makeopts --replace 'chan_ooh323 ' ""
  '';

  postInstall = (old.postInstall or "") + ''
    ln -s ${asteriskDigiumCodecs.opus}/codec_opus.so $out/lib/asterisk/modules/codec_opus.so
    ln -s ${asteriskDigiumCodecs.opus}/format_ogg_opus.so $out/lib/asterisk/modules/format_ogg_opus.so
    ln -s ${asteriskDigiumCodecs.opus}/codec_opus_config-en_US.xml $out/var/lib/asterisk/documentation/thirdparty/codec_opus_config-en_US.xml
    ln -s ${asteriskDigiumCodecs.silk}/codec_silk.so $out/lib/asterisk/modules/codec_silk.so
    ln -s ${asteriskDigiumCodecs.siren7}/codec_siren7.so $out/lib/asterisk/modules/codec_siren7.so
    ln -s ${asteriskDigiumCodecs.siren14}/codec_siren14.so $out/lib/asterisk/modules/codec_siren14.so
    ln -s ${asterisk-g72x}/lib/asterisk/modules/codec_g729.so $out/lib/asterisk/modules/codec_g729.so
  '';
})
