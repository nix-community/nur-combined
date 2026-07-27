{
  sources,

  lib,
  stdenv,

  libvorbis,
}:
stdenv.mkDerivation {
  inherit (sources.snd2acm) pname src;
  version = lib.removePrefix "v" sources.snd2acm.version;

  buildInputs = [
    libvorbis
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r bin $out

    runHook postInstall
  '';

  meta = {
    description = "Sound to ACM converter based on The DragonLance Total Conversion Editor Pro (DLTCEP) code";
    homepage = "https://github.com/dtiefling/snd2acm-portable";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "snd2acm";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
