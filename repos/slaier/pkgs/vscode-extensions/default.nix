{ lib, vscode-utils, sources, ... }:
let
  inherit (lib) filterAttrs mapAttrsToList setAttrByPath foldl;

  isVscodeExtensionSource = source: if source ? collection then source.collection == "vscode-extensions" else false;
  vscodeExtensionSources = filterAttrs (_: isVscodeExtensionSource) sources;

  collect = foldl (l: r: l // r) { };
  forEach = f: mapAttrsToList f vscodeExtensionSources;
in
collect (forEach
  (name: source:
    let
      publisher = source.publisher;
    in
    setAttrByPath [ publisher name ]
      (vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          inherit publisher name;
          inherit (source) version;
        };
        vsix = source.src;
        meta = {
          inherit (source) homepage description;
          license = lib.licenses."${source.license}";
        };
      })
  ))
