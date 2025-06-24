# FLAKE_URI="$PWD" UPDATE_NIX_ATTR_PATH=foo nix run --file ./internal/update-script.nix
let
  system = builtins.currentSystem;
  flake = builtins.getFlake (builtins.getEnv "FLAKE_URI");
  attr = builtins.getEnv "UPDATE_NIX_ATTR_PATH";

  inherit (flake.inputs.nixpkgs) lib;
  pkgs = import flake.inputs.nixpkgs {
    inherit system;
  };

  pkg = flake.packages.${system}.${attr};

  inherit (pkg) name;
  pname = lib.strings.getName pkg;
  version = lib.strings.getVersion pkg;

  updateScriptArgs = builtins.map builtins.toString (
    lib.lists.toList (pkg.updateScript.command or pkg.updateScript)
  );
  updateCommand = lib.strings.escapeShellArgs (updateScriptArgs ++ [ "--commit" ]);
in
pkgs.writeShellScriptBin "update-${attr}" ''
  set -o errexit
  set -o nounset
  set -o pipefail
  set -o xtrace

  trap 'git checkout --quiet main' EXIT
  git checkout --force main
  git checkout -B "update-${attr}"
  old_sha=$(git rev-parse HEAD)

  UPDATE_NIX_NAME=${name} UPDATE_NIX_PNAME=${pname} UPDATE_NIX_OLD_VERSION=${version} UPDATE_NIX_ATTR_PATH=${attr} ${updateCommand}

  new_sha=$(git rev-parse HEAD)
  if [ "$old_sha" == "$new_sha" ]; then
    echo "No commits created" >&2
    exit 0
  fi

  git push --force origin "update-${attr}"

  pr_count=$(gh pr list --head "update-${attr}" --json url --jq 'length')
  if [ "$pr_count" -eq 0 ]; then
    pr_url=$(gh pr create \
      --base "main" \
      --head "update-${attr}" \
      --title "Update ${attr}" \
      --fill-verbose
    )
    gh pr merge --merge --auto "$pr_url"
  fi
''
