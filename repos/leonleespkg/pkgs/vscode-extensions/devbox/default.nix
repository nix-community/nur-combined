{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "devbox";
    publisher = "jetpack-io";
    version = "0.1.8";
    hash = "sha256-2t18JIcjZT4+TDGPLGroLHujl9jtv0/DvOFKW0GNUc0=";
  };

  meta = {
    description = "devbox integration for VSCode";
    longDescription = ''
      Devbox by Jetify integration for Visual Studio Code. Provides a
      seamless development workflow for managing portable, reproducible
      development environments defined by a `devbox.json`.
    '';
    homepage = "https://github.com/jetify-com/devbox";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=jetpack-io.devbox";
    changelog = "https://marketplace.visualstudio.com/items/jetpack-io.devbox/changelog";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
