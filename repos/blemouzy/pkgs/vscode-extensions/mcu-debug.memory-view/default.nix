{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "memory-view";
    publisher = "mcu-debug";
    version = "0.0.29";
    sha256 = "sha256-YZP02EeDe05LQn4gZWSCXndxV70Jfweu+jDu62ElGhI=";
  };

  meta = {
    description = "Standalone Peripheral(SVD) Viewer extension extracted from cortex-debug, now works with any debugger";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mcu-debug.memory-view";
    homepage = "https://github.com/mcu-debug/memview";
    license = lib.licenses.mit;
  };
}
