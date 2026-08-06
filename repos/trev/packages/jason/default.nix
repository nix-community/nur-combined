{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "jason";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "michalmuskala";
    repo = "jason";
    rev = "v${version}";
    hash = "sha256-BYCrWAJwZc2IK49LukSjVoUHt7b5Z6hXLFgziuyouC8=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "A blazing fast JSON parser and generator in pure Elixir";
    homepage = "https://github.com/michalmuskala/jason";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
