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
  version = "11.5.0.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.5.0Build01.dmg";
    url = "https://web.archive.org/web/20260623131534if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1782220507-BcuFy6NJ7LECkbRI-0-62016b469a84b652531a2f3770719b5c";
    hash = "sha256-xAQzutkzBIuu8BGaddZql+tD1hOctPjUSJDoiTcj/Jw=";
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
