{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
  stdenv
}:


stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chatterino";
  version = "2.5.3";

  src = fetchurl {
    url = "https://chatterino.fra1.digitaloceanspaces.com/bin/${finalAttrs.version}/Chatterino.dmg";
    hash = "sha256-pTAw2Ko1fcYxWhQK9j0odQPn28I1Lw2CHLs21KCbo7g=";
  };

  buildInputs = [ undmg ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Chatterino.app $out/Applications
    '';

    meta = {
      homepage = "https://chatterino.com";
      changelog = "https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md";
      description = "Chat client for Twitch";
      license = lib.licenses.mit;
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      broken = !stdenv.isDarwin;
    };
})
