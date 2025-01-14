{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fotoente-neohaj";
  version = "0.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neohaj";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-cES9bZKbor9htR6Ya5baQgtDsVikv2YW2SNiJ+iNLYo=";
  };

  installPhase = ''
    runHook preInstall

    cp -r high-res/png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Source files for the neohaj emoji";
    homepage = "https://codeberg.org/fotoente/neohaj";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
