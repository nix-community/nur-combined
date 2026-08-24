{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juce,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "spectralsuite";
  version = "2.2.0";
  src = fetchFromGitHub {
    owner = "andrewreeman";
    repo = "SpectralSuite";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CqnmF+i7JoAaKQHVx9SwgA566TV0M5BdjibE8ik9AHk=";
  };

  nativeBuildInputs = [ juceCmakeHook ];

  cmakeFlags = [ "-DCPM_JUCE_SOURCE=${juce.src}" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3
    cp -r */*_artefacts/Release/VST3/*.vst3 $out/lib/vst3

    runHook postInstall
  '';

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/andrewreeman/SpectralSuite";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
