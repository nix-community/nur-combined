{
  lib,
  stdenvNoCC,
  upstream,

  fetchurl,
  undmg,
}:
let
  sources = lib.importJSON ./sources.json;
  srcInfo =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

  meta = upstream.qqmusic.meta // {
    platforms = lib.attrNames sources;
  };
  passthru = {
    # nix-update auto -u
    updateScript = ./update.sh;
    _ignoreOverride = true;
  };
in
if stdenvNoCC.hostPlatform.isLinux then
  upstream.qqmusic.overrideAttrs (prevAttrs: {
    inherit (srcInfo) version;
    inherit meta;

    src = fetchurl rec {
      name = "qqmusic_${srcInfo.version}_amd64.deb";
      url = "https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile_plink%2Fmusic_clntupate%2Flinux%2Fother%2F${name}&sign=${srcInfo.sign}";
      inherit (srcInfo) hash;
    };

    passthru = (prevAttrs.passthru or { }) // passthru;
  })
else
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit (upstream.qqmusic) pname;
    inherit (srcInfo) version;
    inherit meta passthru;

    src = fetchurl rec {
      name = "QQMusicMac${srcInfo.version}Build${srcInfo.build}.dmg";
      url = "https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile%2Fmusic_clntupate%2Fmac%2Fother%2F${name}&sign=${srcInfo.sign}";
      inherit (srcInfo) hash;
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
