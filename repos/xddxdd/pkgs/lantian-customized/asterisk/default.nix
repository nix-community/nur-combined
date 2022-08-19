{ lib
, sources
, callPackage
, asterisk
, asteriskDigiumCodecs
, asterisk-g72x
, fetchFromGitHub
, codec2
, libvorbis
, ...
} @ args:

(asterisk.override { withOpus = false; }).overrideAttrs (old: {
  buildInputs = (old.buildInputs or [ ]) ++ [
    codec2
    libvorbis
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
