{ config
, lib
, fetchurl
, callPackage
, vscode-utils
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  baseExtensions = self: lib.mapAttrs (_n: lib.recurseIntoAttrs)
    {
      platformio.platformio-ide = buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "platformio-ide";
          publisher = "platformio";
          version = "2.4.3";
          sha256 = "sha256-pPPukV0LZ/ZFp5Q+O7MhuCK5Px1FPy1ENzl21Ro7KFA=";
        };
        meta = {
          license = lib.licenses.asl20;
        };
      };
    };

  aliases = self: super: {
    ms-vscode = lib.recursiveUpdate super.ms-vscode { inherit (super.golang) go; };
  };
  overlays = lib.optionals config.allowAliases [ aliases ];

  toFix = lib.foldl' (lib.flip lib.extends) baseExtensions overlays;
in
lib.fix toFix
