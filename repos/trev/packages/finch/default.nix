{
  beamPackages,
  fetchFromGitHub,
  hpax,
  lib,
  mime,
  mint,
  nimble_options,
  nimble_pool,
  nix-update-script,
  telemetry,
}:

beamPackages.buildMix rec {
  name = "finch";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "sneako";
    repo = "finch";
    rev = "v${version}";
    hash = "sha256-ZCA/+qdqIA0wh+FL0Ra+ycvOWGPAx3Bw8X7CtCzxdPU=";
  };

  beamDeps = [
    mime
    mint
    nimble_options
    nimble_pool
    telemetry
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "An HTTP client with a focus on performance, built on top of Mint and NimblePool";
    homepage = "https://github.com/sneako/finch";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
