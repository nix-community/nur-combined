{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "nimble_pool";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "dashbitco";
    repo = "nimble_pool";
    rev = "v${version}";
    hash = "sha256-Jta1eJ/cNeH1zPYBj4jQ9yFQxH/myIZ2pR1YW3fMNhI=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "A tiny resource-pool implementation";
    homepage = "https://github.com/dashbitco/nimble_pool";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
