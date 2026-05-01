{ vscode-utils, callPackage }:

let
  pname = "oxc-vscode";
  version = "1.53.0";
  vsix = callPackage ./vsix.nix { inherit pname version; };
in

vscode-utils.buildVscodeExtension {
  inherit pname version vsix;
  src = vsix;

  vscodeExtPublisher = "oxc";
  vscodeExtName = "oxc-vscode";
  vscodeExtUniqueId = "oxc.oxc-vscode";
}
