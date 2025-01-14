{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "moonrabbits-neodog";
  version = "1.1.1";

  src = fetchzip {
    url = "https://git.gay/moonrabbits/neodog/releases/download/${finalAttrs.version}/neodog.tar.gz";
    stripRoot = false;
    hash = "sha256-YQl+/yVYfsp9iqKWl3ExA7JiZJfFoOXg/9XyKvoNkqk=";
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Neodog emojis by @moonrabbits@shonk.phite.ro";
    homepage = "https://git.gay/moonrabbits/neodog";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
