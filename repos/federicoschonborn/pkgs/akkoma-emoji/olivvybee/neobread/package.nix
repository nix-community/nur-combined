{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "olivvybee-neobread";
  version = "2024.09.08.1";

  src = fetchzip {
    url = "https://github.com/olivvybee/emojis/releases/download/${finalAttrs.version}/neobread.tar.gz";
    hash = "sha256-vblyOZlx5FGhaCfjogWk+msH5JcF9JVOH2ySqmYkr6o=";
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
