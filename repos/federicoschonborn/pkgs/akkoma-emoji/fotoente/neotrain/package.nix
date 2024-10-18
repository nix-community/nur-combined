{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neotrain";
  version = "0-unstable-2024-05-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neotrain";
    rev = "48fe8f1a98963998c4829935aef73c67a61e035e";
    hash = "sha256-5yZa9o1kCpzIcW7IRgpKjNRamhpA0aV/YPx8e1u+YNc=";
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
    description = "Source files for the neotrain emoji";
    homepage = "https://codeberg.org/fotoente/neotrain";
    license = lib.licenses.unfree; # TODO: ?
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
