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
  version = "11.8.1.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.8.1Build01.dmg";
    url = "https://web.archive.org/web/20260813121100if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1786622936-6YkgsVn0mxHXGWnm-0-99f3bc119e79fa6516be4123ac6cb694";
    hash = "sha256-5xHOcnt8uv3SgJwcYt53nzY2TMIjjgxrrP2ZrLN/Ozw=";
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
