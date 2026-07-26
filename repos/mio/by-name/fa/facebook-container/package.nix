{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "facebook-container";
  version = "2.3.12";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "contain-facebook";
    tag = finalAttrs.version;
    hash = "sha256-sD38A/RE8y9E0M/SpV1KcZ+w4/PwFYeshiTRPbkDWic=";
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
