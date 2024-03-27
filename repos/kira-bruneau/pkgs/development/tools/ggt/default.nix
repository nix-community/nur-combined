{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-2z+PkL3AYZze4w7FlFEDhsYGsI7dri+wuBV4tuknkgg=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-gLfpyQ0d45ii1Tmcrcp3zKZuOCSAINZedVhvbP/Q+DM=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "The command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    changelog = "https://github.com/gadget-inc/ggt/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
}
