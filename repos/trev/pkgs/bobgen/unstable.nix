{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.40.2-unstable-2025-08-16";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "028664aed3dbc9a73fb2028b4c224f915456cadc";
    hash = "sha256-NqCLy74y7IG8YTb4VbJUrVG7iITyNK3a1S9gENBOVbk=";
  };

  vendorHash = "sha256-3K5ByPBrZRsLcmp0JMNLCcLqQdQizTdxN1Q7B4xe9vc=";

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        "${final.pname}.unstable"
      ];
    });
  };

  meta =
    prev.meta
    // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
})
