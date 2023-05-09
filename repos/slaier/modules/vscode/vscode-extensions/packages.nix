{ lib, vscode-utils }:
let
  buildExt = vscode-utils.buildVscodeMarketplaceExtension;
in
lib.foldl'
  (acc: ext: acc // {
    ${ext.publisher}.${ext.name} = buildExt { mktplcRef = ext; };
  })
{ }
  (lib.importJSON ./exts.json)
