{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neohaj";
  version = "0-unstable-2024-06-08";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neohaj";
    rev = "0e423b38a22504ee541e3ce036a4bfe45586ff5f";
    hash = "sha256-2etDJHGx7DVkgh5uK3YrHIldHQfdDV3FZ6suKVc3yR8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp high-res/png/*.png $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Source files for the neohaj emoji";
    homepage = "https://codeberg.org/fotoente/neohaj";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
