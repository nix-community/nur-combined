{
  lib,
  stdenvNoCC,
  nixpkgs,

  fetchurl,
  undmg,
}:
let
  sources = lib.importJSON ./sources.json;
  srcInfo =
    sources.${stdenvNoCC.hostPlatform.system}
      or sources.${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "any-darwin"}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

  meta = nixpkgs.qqmusic.meta // {
    platforms = lib.remove "any-darwin" (lib.attrNames sources) ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
  passthru = {
    updateScript = ./update.sh;
    _ignoreOverride = true;
  };
in
if stdenvNoCC.hostPlatform.isLinux then
  nixpkgs.qqmusic.overrideAttrs (prevAttrs: {
    inherit (srcInfo) version;
    inherit meta;

    src = fetchurl {
      name = "qqmusic_${srcInfo.version}_amd64.deb";
      inherit (srcInfo) url hash;
    };

    passthru = (prevAttrs.passthru or { }) // passthru;
  })
else
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit (nixpkgs.qqmusic) pname;
    inherit (srcInfo) version;
    inherit meta passthru;

    src = fetchurl {
      name = "QQMusicMac-${srcInfo.version}.dmg";
      inherit (srcInfo) url hash;
    };

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r QQMusic.app $out/Applications

      runHook postInstall
    '';
  })
