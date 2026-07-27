{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.ultramaster-kr-106) pname src;
  version = lib.removePrefix "v" sources.ultramaster-kr-106.version;

  nativeBuildInputs = [ juceCmakeHook ];

  postInstall = ''
    mv "$out/bin/Ultramaster KR-106" $out/bin/KR-106
  '';

  meta = {
    description = "Synthesizer plugin emulating the Roland Juno-6, Juno-60, and Juno-106, built with JUCE";
    homepage = "https://kayrock.org/kr106";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "KR-106";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
