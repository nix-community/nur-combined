# https://github.com/NixOS/nixpkgs/pull/454489
{
  fetchurl,
  lib,
  qqmusic,
  stdenvNoCC,
  undmg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (qqmusic) pname;
  version = "11.3.1.0";

  src = fetchurl rec {
    name = "QQMusicMac11.3.1Build00.dmg";
    url = "https://web.archive.org/web/20260418065109if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1776494997-13kk4HAxkbF0Ae9H-0-deb8d1d13547754a713d335753cfdaf5";
    hash = "sha256-pC9EX3hVwzsWTmnDkhjmMTtjkISDzSMsyBslD1/9ZNo=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r QQMusic.app $out/Applications

    runHook postInstall
  '';

  meta = qqmusic.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
})
