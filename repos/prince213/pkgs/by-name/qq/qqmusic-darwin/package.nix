# https://github.com/NixOS/nixpkgs/pull/454489
{
  lib,
  fetchurl,
  qqmusic,
  stdenvNoCC,

  # nativeBuildInputs
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (qqmusic) pname;
  version = "11.10.0.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.10.0Build01.dmg";
    url = "https://web.archive.org/web/20260924120135if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1790251269-ckAzeRuMooTHE3Cn-0-a1f257fbfcf9c805f8059e06ca235396";
    hash = "sha256-Yr85aUNeBESQIji1tNV+1Ej3Vn4zEgeHKDa0kUAZ+4M=";
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
    platforms = lib.platforms.darwin;
  };
})
