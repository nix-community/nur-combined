{
  beamPackages,
  fetchFromGitHub,
  jason,
  lib,
  nix-update-script,
  req,
  typed_struct,
}:

beamPackages.buildMix rec {
  name = "burrito";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "burrito-elixir";
    repo = "burrito";
    rev = "v${version}";
    hash = "sha256-N4hvGwQKvfGrCi/tmB0pCNmo574equWfcRt66J8+n/4=";
  };

  beamDeps = [
    jason
    req
    typed_struct
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "Wrap your application in a BEAM Burrito";
    homepage = "https://github.com/burrito-elixir/burrito";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
