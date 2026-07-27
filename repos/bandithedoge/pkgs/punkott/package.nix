{
  sources,

  lib,
  stdenv,

  cpm-cmake,
  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.punkott) pname src;
  version = sources.punkott.date;

  nativeBuildInputs = [ juceCmakeHook ];

  cmakeFlags = [ "-DCPM_Catch2_SOURCE=${sources.catch2.src}" ];

  postPatch = ''
    cp ${cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake
  '';

  meta = {
    description = "JUCE audio plugin that pretends to recreate an OTT-style compressor effect";
    homepage = "https://github.com/gmoican/PunkOTT";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
