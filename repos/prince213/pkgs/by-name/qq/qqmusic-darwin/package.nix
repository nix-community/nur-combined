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
  version = "11.9.1.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.9.1Build01.dmg";
    url = "https://web.archive.org/web/20260905082327if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1788596564-5y28LjqPNci1gUMs-0-bab4c4a0428430c9f155fdefadc3d765";
    hash = "sha256-2G3KR2Wuqg6VNkIMcR9YoC2qiOTnKMma68L/x4Bsj2s=";
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
