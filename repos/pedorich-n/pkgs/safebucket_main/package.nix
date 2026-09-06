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
    version = "0.7.5-unstable-2026-09-03";
    src = pkgs.fetchFromGitHub {
      owner = "safebucket";
      repo = "safebucket";
      rev = "2b67f8ad2bcc7c533fe8bc79a7d82ead4ebd411a";
      sha256 = "sha256-ipQf5s1FnczDAI4gjWsXCWSigQbaUVuzAn5Ccny6Nzw=";
    };

    vendorHash = "sha256-RvLu7NpSbtdzxOQAQ/Kkx3IcAT6FIXTBNgDIidvsHRM=";

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
          npmDepsHash = "sha256-x4dgdMXEHhvB+2di+uHY/S/HMx4p901z9AnKvjfY3Rs=";
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
