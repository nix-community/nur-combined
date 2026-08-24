{
  fetchFromGitHub,
  lib,
  callPackage,
  asterisk,
  asteriskDigiumCodecs,
  asterisk-g72x,
  opencore-amr,
  spandsp3,
  codec2,
  libvorbis,
  vo-amrwbenc,
}:
let
  asteriskAmrSrc = fetchFromGitHub {
    owner = "traud";
    repo = "asterisk-amr";
    rev = "420ab33f236e15955351e45bf9fbb256228afe21";
    hash = "sha256-Q8q2fF7MtMlyrVYABaM9V5C0FJj0g9oihE6TLsoe28E=";
  };
  asteriskEvsSrc = fetchFromGitHub {
    owner = "traud";
    repo = "asterisk-evs";
    rev = "c31d342330ddb6e11cb4ac7b516ac5ea409c1fb8";
    hash = "sha256-soayTFbl0FHkH4ZxaeL+ApDsJ2e3CDIIW0KX5rzAAAM=";
  };
  asteriskGsmEfrSrc = fetchFromGitHub {
    owner = "traud";
    repo = "asterisk-gsm-efr";
    rev = "e91ef643a7ff341e1fdaa1c6ff63b3cdc52ac8b4";
    hash = "sha256-EzQA+j2QBilNWgoPzcNEkf/3XO6XNl8ygDD6Q65tdFk=";
  };

  codecs-actual = asteriskDigiumCodecs."${lib.versions.major asterisk.version}";
  asterisk-g72x-actual = asterisk-g72x.override { inherit asterisk; };
  _3gpp-evs = callPackage ./3gpp-evs.nix { };

  # Patches that use patch -p0
  myPatches = [
    "${asteriskAmrSrc}/codec_amr.patch"
    "${asteriskAmrSrc}/build_tools.patch"
    ./codec_evs.patch
    "${asteriskEvsSrc}/build_evs.patch"
    "${asteriskEvsSrc}/force_limitations.patch"
    "${asteriskGsmEfrSrc}/codec_gsm_efr.patch"
  ];

  myExtraFiles = [
    # sources.asterisk-alaw16.src
    asteriskAmrSrc
    asteriskEvsSrc
    asteriskGsmEfrSrc
  ];
in
(asterisk.override { withOpus = false; }).overrideAttrs (old: {
  prePatch =
    (lib.concatStrings (builtins.map (p: "cp -r ${p}/* ./\n") myExtraFiles)) + (old.prePatch or "");

  postPatch =
    (lib.concatStrings (builtins.map (p: "echo ${p}; patch -p0 < ${p}\n") myPatches))
    + (old.postPatch or "");

  # Patches that use patch -p1
  patches = [
    ./mp3player-use-ffmpeg.patch
  ];

  preConfigure = ''
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

  preBuild = (old.preBuild or "") + ''
    sed -i "s/MENUSELECT_ADDONS=.*/MENUSELECT_ADDONS=chan_mobile res_config_mysql/" menuselect.makeopts
    export MAKEFLAGS=-j$(nproc)
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

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Asterisk with Lan Tian modifications";
    platforms = [ "x86_64-linux" ];
  };
})
