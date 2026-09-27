{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  fontconfig,
  freetype,
  alsa-lib,

  installVST3 ? true,
  installCLAP ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anina";
  version = "1.1.1";

  src = fetchzip {
    url = "https://f002.backblazeb2.com/file/crql-works/ANINA/ANINA-Linux-${finalAttrs.version}.zip";
    hash = "sha256-P5w4Sma7JOpmXXO7lux3GV8OuNpDSMsG0Dxup2Ubipc=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig
    freetype
    alsa-lib
  ];

  doNotBuild = true;
  installPhase = ''
    runHook preInstall

    ${lib.optionalString installVST3 ''
      mkdir -p $out/lib/vst3
      cp -r VST3/ANINA.vst3 $out/lib/vst3
    ''}

    ${lib.optionalString installCLAP ''
      mkdir -p $out/lib/clap
      cp CLAP/ANINA.clap $out/lib/clap
    ''}

    runHook postInstall
  '';

  meta = {
    homepage = "https://crql.works/archive/anina/";
  };
})
