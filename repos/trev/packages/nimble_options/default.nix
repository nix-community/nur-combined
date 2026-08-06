{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "nimble_options";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "dashbitco";
    repo = "nimble_options";
    rev = "v${version}";
    hash = "sha256-RefSQXhRR8/uvQm+GtIIq87+9f7H9pW/3MUVCx/Fh7Q=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "A tiny library for validating and documenting high-level options";
    homepage = "https://github.com/dashbitco/nimble_options";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
