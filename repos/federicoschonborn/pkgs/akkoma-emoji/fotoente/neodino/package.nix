{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neodino";
  version = "0-unstable-2025-02-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neodino";
    rev = "8d6084609794ebcbf1025ee479a76fb82b210f44";
    hash = "sha256-PUCtA3ZkUpwJY2gTfCEdJ87jnIBbuFNj8KRsoxH9zZc=";
  };

  installPhase = ''
    runHook preInstall

    cp -r high-res/png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Source files for the neodino emoji";
    homepage = "https://codeberg.org/fotoente/neodino";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
