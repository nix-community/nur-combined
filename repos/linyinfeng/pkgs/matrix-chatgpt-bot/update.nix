{ writeShellScript, yarn2nix }:

writeShellScript "update-matrix-chatgpt-bot" ''
  set -e

  src=$(nix build --no-link --print-out-paths .#matrix-chatgpt-bot.src)

  pushd pkgs/matrix-chatgpt-bot

  function update_file {
    cp "$src/$1" "$1"
    chmod 644 "$1"
  }

  update_file "package.json"
  update_file "yarn.lock"

  ${yarn2nix}/bin/yarn2nix > yarn.nix

  rm yarn.lock

  popd
''
