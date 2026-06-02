{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "debug-tracker-vscode";
    publisher = "mcu-debug";
    version = "0.0.15";
    sha256 = "sha256-2u4Moixrf94vDLBQzz57dToLbqzz7OenQL6G9BMCn3I=";
  };

  meta = {
    description = "A generic debug tracker that provides API/Event services for other extensions";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mcu-debug.debug-tracker-vscode";
    homepage = "https://github.com/mcu-debug/debug-tracker-vscode";
    license = lib.licenses.mit;
  };
}
