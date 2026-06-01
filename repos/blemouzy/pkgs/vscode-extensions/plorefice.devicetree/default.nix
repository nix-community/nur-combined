{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "devicetree";
    publisher = "plorefice";
    version = "0.1.1";
    sha256 = "sha256-udyeY8OuI9+c26WMR63NqElyJLxdMqgOXkkmWF8233k=";
  };

  meta = {
    description = "DeviceTree Language Support for Visual Studio Code";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=plorefice.devicetree";
    homepage = "https://github.com/plorefice/vscode-devicetree";
    license = lib.licenses.mit;
  };
}
