{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "filt-r";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "filtr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-diOM6Y2HrOP5wXg4tVXms7TYOSM16t06ZDg1/Q1L/zc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Envelope based filter modulator";
    homepage = "https://github.com/tiagolr/filtr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "FILT-R";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
