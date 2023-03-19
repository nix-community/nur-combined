{ npmlock2nix, testLib, runCommand, nodejs-16_x, nodejs-17_x, python3 }:
npmlock2nix.v2.node_modules {
  src = ./.;
  sourceOverrides = with npmlock2nix.v2; {
    "ganache" = packageRequirePatchShebangs;
  };
  postCheck = ''
    echo "[+] Checking if the bundled binary shebang has been correctly patched."
    if cat "node_modules/ganache/node_modules/node-gyp-build/bin.js" | head -1 | grep -c "/usr/bin/env"
    then
    echo "ERROR: the bundled node-gyp-build/bin.js file's shebang has not been patched."
    exit 1
    else
    echo "[+] Ok"
    fi
  '';
}
