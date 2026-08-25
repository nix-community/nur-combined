{
  fetchurl,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  dpkg,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wavetable-bin";
  version = "1.0.36";
  src = fetchurl {
    url = "https://github.com/FigBug/Wavetable/releases/download/v${finalAttrs.version}/Wavetable.deb";
    sha256 = "sha256-SfhyapFadNSvOJfmlVlGPrwvVmM2qiUe2HQTiqpjIdQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,lv2,vst3,vst}
    cp -r usr/lib/clap/Wavetable.clap $out/lib/clap
    cp -r usr/lib/lv2/Wavetable.lv2 $out/lib/lv2
    cp -r usr/lib/vst3/Wavetable.vst3 $out/lib/vst3
    cp usr/lib/vst/Wavetable.so $out/lib/vst

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wavetable synth";
    homepage = "https://socalabs.com/synths/wavetable/";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
