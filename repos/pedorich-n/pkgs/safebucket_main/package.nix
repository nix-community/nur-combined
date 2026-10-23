{
  pkgs,
  ...
}:
let
  safebucket = pkgs.callPackage ../safebucket/package.nix { };
in
safebucket.overrideAttrs (
  final: prev: {
    pname = "safebucket_main";
    version = "0.8.0-unstable-2026-10-15";
    src = pkgs.fetchFromGitHub {
      owner = "safebucket";
      repo = "safebucket";
      rev = "99d0a23cd8f1756fda631a64323df2577210212b";
      sha256 = "sha256-aBOPPXedChviNnmXq+o7Cuc88IuHhLdiVvZLtOPllFA=";
    };

    vendorHash = "sha256-+fJq6b+ByFfaXXYGYcqA8FyUvGtP2TweU4nBGjTyKZc=";

    passthru = prev.passthru // {
      updateScript = pkgs.nix-update-script {
        extraArgs = [
          "--flake"
          "--version=branch"
          "--subpackage"
          "frontend"
        ];
      };

      frontend = prev.passthru.frontend.overrideAttrs (
        feFinal: fePrev: {
          npmDepsHash = "sha256-F0pu3mQpGARBnx/OJm7R8FgOLg/w2fel+xjTrXwn8z4=";
          npmDeps = pkgs.fetchNpmDeps {
            inherit (final) src;
            sourceRoot = "${feFinal.src.name}/web";
            hash = feFinal.npmDepsHash;
          };
        }
      );
    };

    meta = prev.meta // {
      description = prev.meta.description + " (tracking main branch)";
    };
  }
)
