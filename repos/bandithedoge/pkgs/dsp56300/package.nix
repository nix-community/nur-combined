{
  enableJE8086 ? true,
  enableNodalRed2x ? true,
  enableOsTIrus ? true,
  enableOsirus ? true,
  enableVavra ? true,
  enableXenia ? true,

  fetchFromGitHub,
  fetchpatch,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dsp56300";
  version = "2.2.27";
  src = fetchFromGitHub {
    owner = "dsp56300";
    repo = "gearmulator";
    rev = finalAttrs.version;
    hash = "sha256-X5Y0w8vf0HReymSxUk435Srbzqvirr5oKdPq5ceQLHk=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/dsp56300/gearmulator/commit/b341b55d9f8f803bb1f616378c57ec3c4b334f9a.patch";
      hash = "sha256-6A86uHFIaRN1Sy4V6jLSJwlIyNZhXXsPJ1E6sY7mYmo=";
    })
  ];

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
    cp source/claudia/n2x/n2xTestConsole/n2xTestConsole $out/bin
  ''
  + lib.optionalString (enableOsirus || enableOsTIrus) ''
    cp source/axel/virusTestConsole/virusTestConsole $out/bin
  ''
  + lib.optionalString enableVavra ''
    cp source/waldi/microq/mqTestConsole/mqTestConsole $out/bin
  ''
  + lib.optionalString enableXenia ''
    cp source/waldi/xt/xtTestConsole/xtTestConsole $out/bin
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
  dontUseMold = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs";
    homepage = "https://dsp56300.wordpress.com/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
