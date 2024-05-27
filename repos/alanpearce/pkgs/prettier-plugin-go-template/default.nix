{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "prettier-plugin-go-template";
  version = "0.0.15";

  src = fetchFromGitHub {
    owner = "NiklasPor";
    repo = "prettier-plugin-go-template";
    rev = "b7fe3eeeeeef69587cca96b85473882a7f52c1c7";
    hash = "sha256-K+BuKzOV0dP67TJLIn6BpAorDesNVp0710AS8XE+RV4=";
  };

  npmDepsHash = "sha256-PpJnVZFRxpUHux2jIBDtyBS4qNo6IJY4kwTAq6stEVQ=";

  npmPackFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "Fixes prettier formatting for go templates 🐹";
    homepage = "https://github.com/NiklasPor/prettier-plugin-go-template";
    license = licenses.mit;
  };
}
