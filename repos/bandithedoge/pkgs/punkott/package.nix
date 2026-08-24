{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  catch2,
  cpm-cmake,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "punkott";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "gmoican";
    repo = "PunkOTT";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9qMiIJEYQUuMoUJynkL6gNluSJHpFXfavXkWxoT6ciY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  cmakeFlags = [ "-DCPM_Catch2_SOURCE=${catch2.src}" ];

  postPatch = ''
    cp ${cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "JUCE audio plugin that pretends to recreate an OTT-style compressor effect";
    homepage = "https://github.com/gmoican/PunkOTT";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
