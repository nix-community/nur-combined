{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "nrf-terminal";
    publisher = "nordic-semiconductor";
    version = "2026.3.289";
    sha256 = "sha256-VQb2nQVPLu6qfTj1IpWBxpTYcxFykSW0fPTR+/HggSI=";
  };

  meta = {
    description = "A serial terminal for VS Code";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nordic-semiconductor.nrf-terminal";
    license = lib.licenses.mit;
  };
}
