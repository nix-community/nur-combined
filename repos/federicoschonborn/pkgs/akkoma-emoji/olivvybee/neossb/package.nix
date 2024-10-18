{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "olivvybee-neossb";
  version = "2024.10.14.1";

  src = fetchzip {
    url = "https://github.com/olivvybee/emojis/releases/download/${finalAttrs.version}/neossb.tar.gz";
    hash = "sha256-+4pHxLriFcB8Ryq44nim4sn4E7ENVaMEftsda67Vt7c=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

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
