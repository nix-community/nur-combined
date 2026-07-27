{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.cloudreverb) pname src;
  version = sources.cloudreverb.date;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "algorithmic reverb plugin based on CloudSeed";
    homepage = "https://github.com/xunil-cloud/CloudReverb";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "CloudReverb";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
