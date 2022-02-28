{ pkgs }:
let
  qutebrowser-start-page = pkgs.haskellPackages.callPackage ./haskellExecutable.nix { };
  qutebrowser-start-page-css = pkgs.callPackage ./tailwindCss.nix {};
in
  pkgs.writeShellScriptBin "qutebrowser-start-page" ''
    exec ${qutebrowser-start-page}/bin/qutebrowser-start-page ${qutebrowser-start-page-css}/css/output.css
  ''
