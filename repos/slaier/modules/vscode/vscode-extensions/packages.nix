{ lib, vscode-utils, stdenv, autoPatchelfHook }:
let
  buildExt = vscode-utils.buildVscodeMarketplaceExtension;
  patchElf = {
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ (lib.getLib stdenv.cc.cc) ];
  };
in
lib.foldl'
  (acc: ext: acc // {
    ${ext.publisher}.${ext.name} = buildExt ({ mktplcRef = ext; } // (lib.optionalAttrs (ext ? arch) patchElf));
  })
{ }
  (lib.importJSON ./exts.json)
