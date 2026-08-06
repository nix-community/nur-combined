{
  beamPackages,
  fetchFromGitHub,
  hpax,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "mint";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "elixir-mint";
    repo = "mint";
    rev = "v${version}";
    hash = "sha256-PcamfEOMZGL5lKZJaOTCqt4KRV2rBJrWcdK/8jWPvxc=";
  };

  beamDeps = [ hpax ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "Functional HTTP client for Elixir with support for HTTP/1 and HTTP/2";
    homepage = "https://github.com/elixir-mint/mint";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
