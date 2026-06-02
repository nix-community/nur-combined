{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "doxdocgen";
    publisher = "cschlosser";
    version = "1.4.0";
    sha256 = "sha256-InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
  };

  meta = {
    description = "Let me generate Doxygen documentation from your source code for you";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=cschlosser.doxdocgen";
    homepage = "https://github.com/cschlosser/doxdocgen";
    license = lib.licenses.mit;
  };
}
