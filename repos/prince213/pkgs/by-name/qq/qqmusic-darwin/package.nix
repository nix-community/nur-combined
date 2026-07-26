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
  version = "11.7.0.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl rec {
    name = "QQMusicMac11.7.0Build02.dmg";
    url = "https://web.archive.org/web/20260725075011if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1784965795-mE787kwAIR9azxLt-0-de7361f4895e046ab95e7f9d6efcbf9a";
    hash = "sha256-Y4Voh7qB39Z2RwaQKVnJcEsU+aABYmYzsrUpPFmQtWE=";
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
