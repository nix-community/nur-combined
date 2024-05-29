{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-kuMSn9VvRjy69LpNQhgJYpyemXbJd/37vU5sjf2EhOM=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-CqJTUHSnezzoVhUyQ8xZ3RqrL6V+XbP4ihIHGvaVQ0w=";

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
