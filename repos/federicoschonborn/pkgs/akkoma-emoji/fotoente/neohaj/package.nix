{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neohaj";
  version = "0-unstable-2024-07-29";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neohaj";
    rev = "7e1e37008adf94ddae9fac7eae36830c147ba4f7";
    hash = "sha256-XWWaDF0uCihU+Uwm4pexNkGIB45WAbtq5C0E848BdgU=";
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
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
