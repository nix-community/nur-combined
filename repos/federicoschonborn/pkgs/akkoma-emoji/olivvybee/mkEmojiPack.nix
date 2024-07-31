{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

{ name, hash }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "olivvybee-${name}";
  version = "2024.07.30.1";

  src = fetchzip {
    url = "https://github.com/olivvybee/emojis/releases/download/${finalAttrs.version}/${name}.tar.gz";
    inherit hash;
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
