{
  enableJE8086 ? true,
  enableNodalRed2x ? true,
  enableOsTIrus ? true,
  enableOsirus ? true,
  enableVavra ? true,
  enableXenia ? true,

  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.dsp56300) pname version src;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  postPatch = ''
    substituteAll CMakeLists.txt --replace-fail "/usr/local" "${placeholder "out"}"
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
  ''
  + lib.optionalString enableJE8086 ''
    cp source/ronaldo/je8086/jeTestConsole/JE8086TestConsole $out/bin
  ''
  + lib.optionalString enableNodalRed2x ''
    cp source/nord/n2x/n2xTestConsole/n2xTestConsole $out/bin
  ''
  + lib.optionalString (enableOsirus || enableOsTIrus) ''
    cp source/virusTestConsole/virusTestConsole $out/bin
  ''
  + lib.optionalString enableVavra ''
    cp source/mqTestConsole/mqTestConsole $out/bin
  ''
  + lib.optionalString enableXenia ''
    cp source/xtTestConsole/xtTestConsole $out/bin
  ''
  + ''
    cd ../bin/plugins/Release
    cp -r CLAP $out/lib/clap
    cp -r VST3 $out/lib/vst3
    cp -r VST $out/lib/vst
  '';

  cmakeFlags = [
    (lib.cmakeBool "gearmulator_SYNTH_JE8086" enableJE8086)
    (lib.cmakeBool "gearmulator_SYNTH_NODALRED2X" enableNodalRed2x)
    (lib.cmakeBool "gearmulator_SYNTH_OSIRUS" enableOsirus)
    (lib.cmakeBool "gearmulator_SYNTH_OSTIRUS" enableOsTIrus)
    (lib.cmakeBool "gearmulator_SYNTH_VAVRA" enableVavra)
    (lib.cmakeBool "gearmulator_SYNTH_XENIA" enableXenia)
  ];

  dontUseJuceInstall = true;

  meta = {
    description = "Emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs";
    homepage = "https://dsp56300.wordpress.com/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
