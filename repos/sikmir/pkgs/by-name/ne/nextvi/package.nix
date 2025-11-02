{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    tag = finalAttrs.version;
    hash = "sha256-FBUcmCkGOf7HVLkZqHWxHxS0qhz5t9VwbWb0VOGnb28=";
  };

  buildPhase = ''
    runHook preBuild
    sh ./cbuild.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out sh ./cbuild.sh install
    runHook postInstall
  '';

  meta = {
    description = "Next version of neatvi (a small vi/ex editor)";
    homepage = "https://github.com/kyx0r/nextvi";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "vi";
  };
})
