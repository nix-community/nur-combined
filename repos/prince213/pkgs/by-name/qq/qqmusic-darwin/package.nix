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
  version = "11.11.1.73285";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "mwejkbzw-5e214dcd248f1b2e.dmg";
    url = "https://web.archive.org/web/20261116054354if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1794807829-czySdTIJBWJp9tgE-0-aace9f449c0b65e1173b53a9a40abee5";
    hash = "sha256-zXfXmie8k9WwaPg41pmXY18hxBIFLr1X4nzGGPQFPA8=";
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
