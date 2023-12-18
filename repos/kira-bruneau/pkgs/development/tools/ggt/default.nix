{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-3wSfbuSURLiYPNKb+blhrcACrIR+5lKLEFJEsl8HYbA=";
  };

  patches = [
    ./fix-resolved.patch
  ];

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-N0klpRyJeAc/KagPgR0a7eC50BK/ZXYmyJsXvIHE9pA=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "The command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
}
