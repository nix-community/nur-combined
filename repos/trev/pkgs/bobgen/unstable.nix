{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.39.0-unstable-2025-08-07";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "1a6196ec4705646e13923a932f7f73c066e911ca";
    hash = "sha256-PIIN88BVddVc3/GFsYEkrgADoI2IDuhCFqwLgyyCPrg=";
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
