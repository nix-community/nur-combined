{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "mime";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "elixir-plug";
    repo = "mime";
    rev = "v${version}";
    hash = "sha256-n0fCYzkSu9awZJOtUuI4C4VP8ywvdS1cYeH/iPvpf/0=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "A MIME type module for Elixir";
    homepage = "https://github.com/elixir-plug/mime";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
