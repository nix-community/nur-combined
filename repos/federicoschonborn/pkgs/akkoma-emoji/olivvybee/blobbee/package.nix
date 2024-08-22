{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "olivvybee-blobbee";
  version = "2024.08.21.1";

  src = fetchzip {
    url = "https://github.com/olivvybee/emojis/releases/download/${finalAttrs.version}/blobbee.tar.gz";
    hash = "sha256-49xea5PeWDShPajXnAOPDGMXF9CMTUlYJERWCg93s7M=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp *.png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Various emoji packs from Liv Asch";
    homepage = "https://github.com/olivvybee/emojis";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
