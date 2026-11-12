{
  lib,
  fetchurl,
  vscode-utils,
}:
# Apple publishes this extension only as a GitHub release VSIX (publisher `Pkl`);
# it is absent from both the marketplace and open-vsx, so there is no
# `buildVscodeMarketplaceExtension` source and the artifact is pinned by hand.
#
# The packaged LSP (`out/pkl-lsp.jar`, ~38 MB) is started with Java >= 22 found
# through `$JAVA_HOME` or `$PATH`; the extension warns and offers a settings
# entry when neither has a suitable JVM (nixpkgs `jdk22`/`jdk` satisfy it).
vscode-utils.buildVscodeExtension rec {
  pname = "pkl-vscode";
  version = "0.24.0";

  src = fetchurl {
    url = "https://github.com/apple/pkl-vscode/releases/download/${version}/pkl-vscode-${version}.vsix";
    hash = "sha256-jIoGG+zxiH7EHMT1ohQQapg7czdY4vOTg0BVo5g0XgI=";
  };

  vscodeExtPublisher = "Pkl";
  vscodeExtName = "pkl-vscode";
  vscodeExtUniqueId = "Pkl.pkl-vscode";

  meta = with lib; {
    description = "Pkl language support for Visual Studio Code";
    homepage = "https://github.com/apple/pkl-vscode";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = platforms.all;
  };
}
