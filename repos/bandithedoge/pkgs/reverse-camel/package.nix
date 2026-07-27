{
  sources,

  lib,
  stdenv,

  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.reverse-camel) pname src;
  version = lib.removePrefix "v" sources.reverse-camel.version;

  nativeBuildInputs = [
    pkg-config
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{lv2,vst,ladspa,dssi}
    cp -r bin/reverse-camel.lv2 $out/lib/lv2
    cp bin/reverse-camel-vst.so $out/lib/vst
    cp bin/reverse-camel-ladspa.so $out/lib/ladspa
    cp bin/reverse-camel-dssi.so $out/lib/dssi

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Cross-platform Camel Crusher Clone VST plug-in based on black-box analysis";
    homepage = "https://github.com/soerenbnoergaard/reverse-camel";
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
