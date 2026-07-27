{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.unplugred) pname src;
  version = sources.unplugred.date;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  patches = [
    # HACK: https://github.com/unplugred/vsts/issues/7
    ./remove_fmplus.patch
  ];

  preInstall = ''
    cp -r plugins/*/*_artefacts .
  '';

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}"
    "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${sources.clap-juce-extensions.src}"
  ];

  meta = {
    description = "Collection of VST plugins made by unplugred";
    homepage = "https://vst.unplug.red";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    broken = true;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
