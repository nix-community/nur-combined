{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-0jcpjINqQ0TO3vNJYR8AsnCOr2Qu5OK1BPkGQm22a20=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-QIVRS/Nkea+0yMTaWG6yPhv2+d68zdcHaAfznmOVTZ4=";

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
