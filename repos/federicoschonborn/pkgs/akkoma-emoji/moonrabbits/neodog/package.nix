{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "moonrabbits-neodog";
  version = "1.1.0";

  src = fetchzip {
    url = "https://git.gay/moonrabbits/neodog/releases/download/${finalAttrs.version}/neodog.tar.gz";
    stripRoot = false;
    hash = "sha256-CbK/tDAvNVC4LSZuTCNHRKnQO0TiV2i9m8fitJvM848=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp *.png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Neodog emojis by @moonrabbits@shonk.phite.ro";
    homepage = "https://git.gay/moonrabbits/neodog";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
