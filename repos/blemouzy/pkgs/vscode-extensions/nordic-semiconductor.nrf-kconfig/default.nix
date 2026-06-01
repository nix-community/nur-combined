{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "nrf-kconfig";
    publisher = "nordic-semiconductor";
    version = "2026.1.230";
    sha256 = "sha256-x8FscOLnwh9qPO4HrmnhYeMnAb3iLewofRlWJH+rH7E=";
  };

  meta = {
    description = "Kconfig language support for the Zephyr Project";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nordic-semiconductor.nrf-kconfig";
    license = lib.licenses.mit;
  };
}
