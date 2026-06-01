{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "yocto-bitbake";
    publisher = "yocto-project";
    version = "2.8.0";
    sha256 = "sha256-FCgZ3yG4WQGTxJ6Z9AFRycX7owUU9/1xrNzC1WjzvgA=";
  };

  meta = {
    description = "Extended Yocto Project and BitBake language support";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=yocto-project.yocto-bitbake";
    homepage = "https://github.com/yoctoproject/vscode-bitbake";
    license = lib.licenses.mit;
  };
}
