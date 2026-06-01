{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "rtos-views";
    publisher = "mcu-debug";
    version = "0.0.15";
    sha256 = "sha256-yytAP5U7urgKLcQO0rp6jlcxIVzDls6jWddaojTV6nQ=";
  };

  meta = {
    description = "RTOS views for microcontrollers";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mcu-debug.rtos-views";
    homepage = "https://github.com/mcu-debug/rtos-views";
    license = lib.licenses.mit;
  };
}
