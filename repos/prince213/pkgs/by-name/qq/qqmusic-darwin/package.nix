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
  version = "11.10.5.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.10.5Build00.dmg";
    url = "https://web.archive.org/web/20261014093922if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1791970498-taoEpa64RH9F5GOa-0-b906f64014f8e7fe6503f6dde7a55259";
    hash = "sha256-LkEU8DElkEe9wivvGlhXYwQl9UIveOZZFt0QtfNMuwk=";
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
