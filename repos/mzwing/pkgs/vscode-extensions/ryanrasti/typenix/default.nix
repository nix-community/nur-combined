{
  lib,
  vscode-utils,
  typenix-vscode,
}:
vscode-utils.buildVscodeExtension {
  pname = "ryanrasti-typenix";
  inherit (typenix-vscode) version;

  src = "${typenix-vscode}/typenix.vsix";

  vscodeExtPublisher = "ryanrasti";
  vscodeExtName = "typenix";
  vscodeExtUniqueId = "ryanrasti.typenix";

  # Not published on the Marketplace; disable the default marketplace updateScript
  passthru.updateScript = null;

  meta = {
    description = "Full TypeScript-grade typing for Nix — autocomplete, type errors, hover docs, go-to-definition";
    homepage = "https://github.com/ryanrasti/typenix";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
