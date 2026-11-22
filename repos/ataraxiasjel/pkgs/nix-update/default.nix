{
  lib,
  callPackage,
  fetchFromGitHub,
  nix,
  nix-prefetch-git,
  nixpkgs-review,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nix-update";
  version = "1.17.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TCOhUWb53V3nrJRD3JuADly1U9fNi0Z79QMcjhbefHg=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = [ python3Packages.ast-grep-py ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      nix
      nix-prefetch-git
      nixpkgs-review
    ])
  ];

  checkPhase = ''
    runHook preCheck

    $out/bin/nix-update --help >/dev/null

    runHook postCheck
  '';

  passthru = rec {
    nix-update-script = callPackage ./nix-update-script.nix { nix-update = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Swiss-knife for updating nix packages";
    homepage = "https://github.com/Mic92/nix-update/";
    changelog = "https://github.com/Mic92/nix-update/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "nix-update";
  };
})
