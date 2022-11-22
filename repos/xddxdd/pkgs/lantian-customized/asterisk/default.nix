{ lib
, sources
, callPackage
, asterisk_20
, asteriskDigiumCodecs_20
, asterisk-g72x
, fetchFromGitHub
, codec2
, libvorbis
, ...
} @ args:

let
  asterisk-actual = asterisk_20;
  codecs-actual = asteriskDigiumCodecs_20;
  asterisk-g72x-actual = asterisk-g72x.override { asterisk = asterisk-actual; };
in
(asterisk-actual.override { withOpus = false; }).overrideAttrs (old: {
  buildInputs = (old.buildInputs or [ ]) ++ [
    codec2
    libvorbis
  ];

  preBuild = (old.preBuild or "") + ''
    substituteInPlace menuselect.makeopts --replace 'chan_ooh323 ' ""
  '';

  postInstall = (old.postInstall or "") + ''
    ln -s ${codecs-actual.opus}/codec_opus.so $out/lib/asterisk/modules/codec_opus.so
    ln -s ${codecs-actual.opus}/format_ogg_opus.so $out/lib/asterisk/modules/format_ogg_opus.so
    ln -s ${codecs-actual.opus}/codec_opus_config-en_US.xml $out/var/lib/asterisk/documentation/thirdparty/codec_opus_config-en_US.xml
    ln -s ${codecs-actual.silk}/codec_silk.so $out/lib/asterisk/modules/codec_silk.so
    ln -s ${codecs-actual.siren7}/codec_siren7.so $out/lib/asterisk/modules/codec_siren7.so
    ln -s ${codecs-actual.siren14}/codec_siren14.so $out/lib/asterisk/modules/codec_siren14.so
    ln -s ${asterisk-g72x-actual}/lib/asterisk/modules/codec_g729.so $out/lib/asterisk/modules/codec_g729.so
  '';

  meta.platforms = [ "x86_64-linux" ];
})
