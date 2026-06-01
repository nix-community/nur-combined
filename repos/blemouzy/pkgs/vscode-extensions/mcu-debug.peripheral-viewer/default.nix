{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "peripheral-viewer";
    publisher = "mcu-debug";
    version = "1.6.1";
    sha256 = "sha256-DwaL0lct8KevC7AVFLydQTQEr1mC1Rz+P+jl+zHoN+k=";
  };

  meta = {
    description = "Standalone Peripheral(SVD) Viewer extension extracted from cortex-debug, now works with any debugger";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mcu-debug.peripheral-viewer";
    homepage = "https://github.com/mcu-debug/peripheral-viewer";
    license = lib.licenses.mit;
  };
}
