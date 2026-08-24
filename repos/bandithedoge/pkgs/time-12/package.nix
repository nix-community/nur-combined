{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "time-12";
  version = "1.2.3";
  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "time12";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/siQGQRHPqIP17NE4e/IGEQIzLPnBAXXzU6ucL1y5os=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Envelope based delay modulator";
    homepage = "https://github.com/tiagolr/time12";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "TIME-12";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
