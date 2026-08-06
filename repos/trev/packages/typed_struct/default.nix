{
  beamPackages,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "typed_struct";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ejpcmac";
    repo = "typed_struct";
    rev = "v${version}";
    hash = "sha256-WhtDS8Q1bJh/3e6l2SZ3caisaFCO651Zc7yMu7icqkE=";
  };

  beamDeps = [ ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "A library for defining structs with typed fields";
    homepage = "https://github.com/ejpcmac/typed_struct";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
