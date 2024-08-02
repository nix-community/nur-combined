{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fotoente-neohaj";
  version = "0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neohaj";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jZOxzR2gAjIVoQcIQTBwdWZ+L9a/Llge5pHTcdIMDdQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp high-res/png/*.png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Source files for the neohaj emoji";
    homepage = "https://codeberg.org/fotoente/neohaj";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
