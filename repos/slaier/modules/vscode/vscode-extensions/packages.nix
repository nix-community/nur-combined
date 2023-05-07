{ lib, vscode-utils }:
let
  buildExt = vscode-utils.buildVscodeMarketplaceExtension;
in
lib.mergeAttrList (map
  (ext: { ${ext.publisher}.${ext.name} = buildExt { mktplcRef = ext; }; })
  (builtins.fromJSON (builtins.readFile ./exts.json)))
