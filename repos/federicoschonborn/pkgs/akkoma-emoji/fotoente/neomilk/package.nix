{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neomilk";
  version = "0-unstable-2025-02-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neomilk";
    rev = "760e8049100498bfabfea2a031dbab545eb55402";
    hash = "sha256-duapijE8UUGPMFH/kF5R6Q5eTTE8MeYi3Yoos2/6+qQ=";
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
