{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gate-12";
  version = "1.3.3";
  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "gate12";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dyeIWD315+aKZRwtkRYaWNOS8bNDFboMVPHHe7l+IIY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GATE-12 is a cross-platform envelope generator for gate/volume control inspired by plugins like GrossBeat and ShaperBox. It is the second version of GATE-1 rebuilt from scratch using the JUCE framework";
    homepage = "https://github.com/tiagolr/gate12";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "GATE-12";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
