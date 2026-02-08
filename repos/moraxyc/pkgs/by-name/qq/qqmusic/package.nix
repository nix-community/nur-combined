{
  lib,
  stdenvNoCC,
  upstream,

  fetchurl,
  undmg,
}:
if stdenvNoCC.hostPlatform.isLinux then
  upstream.qqmusic
else
  stdenvNoCC.mkDerivation (
    finalAttrs:
    let
      srcInfo =
        (lib.importJSON ./sources.json).${stdenvNoCC.hostPlatform.system}
          or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
    in
    {
      inherit (upstream.qqmusic) pname;
      inherit (srcInfo) version;

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

      passthru = {
        # nix-update auto -u
        updateScript = ./update.sh;
        _ignoreOverride = true;
      };

      meta = upstream.qqmusic.meta // {
        platforms = [
          "aarch64-darwin"
          "x86_64-darwin"
          "x86_64-linux"
        ];
      };
    }
  )
