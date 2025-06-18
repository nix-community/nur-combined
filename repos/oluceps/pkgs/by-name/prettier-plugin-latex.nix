{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "prettier-plugin-latex";
  version = "0-unstable";

  src = fetchFromGitHub {
    owner = "siefkenj";
    repo = "prettier-plugin-latex";
    rev = "ce2d9853cfb9e17b5de4168065b77c853a4b5050";
    hash = "sha256-cfYCh4Le07liALkT5qXjAe1ZRuAlq+DEpcL2goWB/K0=";
  };

  npmDepsHash = "sha256-sj26NkqD46kMBuoIeC4MPRSjPIMjU1pR0WM3PyexXaw=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = {
    description = "Plugin to format LaTeX with prettier.js";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
  };
})
