{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-Y5obv/iPIqEEY0jhi1DfGNzeTLBM2Zh6FH4PPVJ4QAQ=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-6dcsFejVcPpv7O+QaSJtgNcx/r9xWgjBXzz1qtoZoMk=";

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
