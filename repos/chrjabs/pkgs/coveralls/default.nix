{
  lib,
  crystal,
  fetchFromGitHub,
  openssl,
}:
crystal.buildCrystalPackage rec {
  version = "0.6.15";
  pname = "coveralls";
  src = fetchFromGitHub {
    owner = "coverallsapp";
    repo = "coverage-reporter";
    rev = "v${version}";
    hash = "sha256-zNpHQJed3LRjTN/+UJEIj9N2ldLJsirO/NWvzp25SFo=";
  };

  shardsFile = ./shards.nix;
  crystalBinaries.coveralls.src = "src/cli.cr";

  buildInputs = [ openssl ];
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv bin/coveralls $out/bin/coveralls

    runHook postInstall
  '';

  meta = {
    description = "Self-contained, universal coverage uploader binary. Under development.";
    homepage = "https://github.com/coverallsapp/coverage-reporter";
    license = lib.licenses.mit;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "coveralls";
  };
}
