{
  sources,

  lib,
  stdenv,

  git,
  juceCmakeHook,
  libjack2,
}:
stdenv.mkDerivation {
  inherit (sources.monique) pname src;
  version = sources.monique.date;

  nativeBuildInputs = [
    juceCmakeHook
    git
  ];

  buildInputs = [
    libjack2
  ];

  meta = {
    description = "Monique monosynth";
    homepage = "https://github.com/surge-synthesizer/monique-monosynth";
    license = with lib.licenses; [
      gpl3Plus
      mit
    ];
    platforms = lib.platforms.linux;
    broken = true; # hash shenanigans
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
