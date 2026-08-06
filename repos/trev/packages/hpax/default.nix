{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "hpax";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "elixir-mint";
    repo = "hpax";
    rev = "v${version}";
    hash = "sha256-O8BRwr61IyPYyChLOJITEscnceo0HUKaDYRySOrCP6k=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "HPACK Implementation for Elixir";
    homepage = "https://github.com/elixir-mint/hpax";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
