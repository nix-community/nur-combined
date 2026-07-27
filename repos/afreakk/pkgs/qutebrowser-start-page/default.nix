{ pkgs }:
let
  src = pkgs.fetchFromGitHub {
    rev = "d68508970fb66b57be0915ac51a0d37e4be7476f";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "sha256-e2UrWcxU2qbJwJmKsrbp8cukvlchFP+zQ4+0+B9YR8s=";
  };
  qutebrowser-start-page = pkgs.haskellPackages.callPackage ./haskellExecutable.nix { inherit src; };
  qutebrowser-start-page-css = pkgs.callPackage ./tailwindCss.nix { inherit src; };
in
  pkgs.writeShellScriptBin "qutebrowser-start-page" ''
    exec ${qutebrowser-start-page}/bin/qutebrowser-start-page ${qutebrowser-start-page-css}/css/output.css
  ''
