{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "nrf-devicetree";
    publisher = "nordic-semiconductor";
    version = "2026.3.617";
    sha256 = "sha256-8YfwY/qZ//XYWJZmHHFpWcbABzngBmCRTG3e0TdhyJs=";
  };

  meta = {
    description = "Full DeviceTree language support for the Zephyr project";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nordic-semiconductor.nrf-devicetree";
    license = lib.licenses.mit;
  };
}
