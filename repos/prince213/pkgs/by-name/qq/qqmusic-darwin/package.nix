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
  version = "11.8.0.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.8.0Build02.dmg";
    url = "https://web.archive.org/web/20260803144330if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1785768194-qXyRvNpxK9ZGy23l-0-42cba27e0a0ae6b6f732e53e04125247";
    hash = "sha256-UQ/tKSQmKo4pzHtbs/8clE3SJzt+JdiCtirsxgwuDUY=";
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
