{
  lib,
  writers,
  writeShellScriptBin,
  nix,
  node2nix,
}:
let
  packageNames = [
    "@anthropic-ai/claude-code"
    "@modelcontextprotocol/inspector"
    "@modelcontextprotocol/server-filesystem"
  ];
  packageNamesJSON = writers.writeJSON "node-packages.json" packageNames;

  updateScript = writeShellScriptBin "update-node-packages" ''
    set -o errexit
    set -o xtrace
    export PATH=${
      lib.strings.makeBinPath [
        nix
        node2nix
      ]
    }
    pushd pkgs/node2nix
    node2nix --input ${packageNamesJSON} --composition /dev/null
    popd
    nix fmt
  '';
in
updateScript
