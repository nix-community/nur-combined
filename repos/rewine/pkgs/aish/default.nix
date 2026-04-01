{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aish";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AI-Shell-Team";
    repo = "aish";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HxYlXD+4Vfs5RcXnF17nL28B1x86KpqtFytaRk1IsmQ=";
  };

  meta = {
    description = "Empower the Shell to think. Evolve Operations";
    homepage = "https://github.com/AI-Shell-Team/aish";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aish";
    platforms = lib.platforms.all;
  };
})
