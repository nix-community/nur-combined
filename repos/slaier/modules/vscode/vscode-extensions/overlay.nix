final: prev:
let
  newExtensions = final.callPackage ./packages.nix { };
in
{
  vscode-extensions = final.lib.recursiveUpdate prev.vscode-extensions newExtensions;
}
