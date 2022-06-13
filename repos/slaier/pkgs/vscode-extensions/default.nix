{ pkgs, sources, ... }:
let
  inherit (pkgs.lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (pkgs.lib.strings) splitString hasPrefix removePrefix removeSuffix;

  strip = char: name: removePrefix char (removeSuffix char name);
  vscodeExtensionSources = filterAttrs (n: _: hasPrefix "'vscode-extensions." n) sources;
in
mapAttrs'
  (sourceName: source:
    let
      sn = strip "'" sourceName;
      l = splitString "." sn;
      publisher = builtins.elemAt l 1;
      name = builtins.elemAt l 2;
    in
    nameValuePair "vscode-extension-${publisher}-${name}"
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          inherit publisher name;
          inherit (source) version;
        };
        vsix = source.src;
        meta = {
          inherit (source) homepage description;
          license = pkgs.lib.licenses."${source.license}";
        };
      })
  )
  vscodeExtensionSources

