{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule {
  pname = "testscript";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "rogpeppe";
    repo = "go-internal";
    tag = "v1.13.1";
    hash = "sha256-fD4n3XVDNHL7hfUXK9qi31LpBVzWnRK/7LNc3BmPtnU=";
  };

  vendorHash = "sha256-rX2xcv409FoC9vO65iLj7w+S8ykBG+6aE3ooD0h1Abg=";

  subPackages = [
    "cmd/testscript"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Provides a shell-like test environment that is very nicely tuned for testing Go CLI commands";
    homepage = "https://github.com/rogpeppe/go-internal";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    mainProgram = "testscript";
  };
}
