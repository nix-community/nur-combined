{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "facebook-container";
  version = "2.3.11";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "contain-facebook";
    tag = finalAttrs.version;
    hash = "sha256-T9VjUQt/RWYmmUFf4lKPvzyF48RyWNLjPr3tVg1lpc4=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/facebook-container
    cp -r src/. $out/share/facebook-container/
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/mozilla/contain-facebook/releases/tag/${finalAttrs.version}";
    description = "Facebook Container — prevent Facebook from tracking you across the web";
    homepage = "https://github.com/mozilla/contain-facebook";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
