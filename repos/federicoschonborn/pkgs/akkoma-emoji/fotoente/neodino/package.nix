{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fotoente-neodino";
  version = "0-unstable-2024-06-08";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fotoente";
    repo = "neodino";
    rev = "39efa5e7226a73e68200ba8e6ef35d36bc1dce4a";
    hash = "sha256-NAFKFuPXXHBMXiPae/VYgFT2uCgb0RP/HpTIE2P1efA=";
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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
