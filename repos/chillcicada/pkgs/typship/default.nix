{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  perl,
}:

rustPlatform.buildRustPackage rec {
  pname = "typship";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "sjfhsjfh";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-e7jGc/ENVEMGzXl+sidzNBFy+qZo9+ClRPYhsXtnyD8=";
  };

  sourceRoot = src.name;

  cargoHash = "sha256-lRB+GL5dgl22B+qBZV273V9tavGu5HqK2Z9JFyqVoK8=";

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = " A Typst package CLI tool";
    homepage = "https://github.com/sjfhsjfh/typship";
    license = licenses.mit;
    mainProgram = "typship";
  };
}
