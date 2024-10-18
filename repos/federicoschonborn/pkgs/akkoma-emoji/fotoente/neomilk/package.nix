{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neomilk";
  version = "0-unstable-2024-05-26";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neomilk";
    rev = "2470553da8dccd2ebd5d08fb859b60d59ab4692d";
    hash = "sha256-UlsiWGuWgJpyldKTnuCxPShTNOFah3z8x1B06iX7mtI=";
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
    description = "Source files for the neomilk emoji";
    homepage = "https://codeberg.org/fotoente/neomilk";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
