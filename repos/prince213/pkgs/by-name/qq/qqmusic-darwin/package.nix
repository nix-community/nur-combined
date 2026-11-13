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
  version = "11.11.0.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.11.0Build01.dmg";
    url = "https://web.archive.org/web/20261113034112if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1794541271-2bA7YlHlQRiDSHX8-0-bbe72b3027a080bd866f64ce09a48593";
    hash = "sha256-8taBUf8nuhoZrfxtnCWfLL6/gLUIVNqtVBkgT9s7bis=";
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
