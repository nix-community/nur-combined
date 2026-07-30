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
  isNixUpdate = lib.strings.hasSuffix "/bin/nix-update" (builtins.head updateScriptArgs);
  updateCommand = lib.strings.escapeShellArgs (
    updateScriptArgs ++ lib.lists.optional isNixUpdate "--flake" ++ [ "--commit" ]
  );

  inherit (lib.strings) escapeShellArg;
  branch = escapeShellArg "update-${attr}";
in
pkgs.writeShellApplication {
  name = "update-${attr}";

  runtimeInputs = [
    pkgs.gh
    pkgs.git
  ];

  text = ''
    set -o xtrace

    trap 'git checkout --quiet --force main' EXIT
    git checkout --force main
    git checkout -B ${branch}
    old_sha=$(git rev-parse HEAD)

    UPDATE_NIX_NAME=${escapeShellArg name} UPDATE_NIX_PNAME=${escapeShellArg pname} UPDATE_NIX_OLD_VERSION=${escapeShellArg version} UPDATE_NIX_ATTR_PATH=${escapeShellArg attr} ${updateCommand}

    new_sha=$(git rev-parse HEAD)
    if [ "$old_sha" = "$new_sha" ]; then
      echo "No commits created" >&2
      exit 0
    fi

    git push --force origin ${branch}

    pr_count=$(gh pr list --head ${branch} --json url --jq 'length')
    if [ "$pr_count" -eq 0 ]; then
      gh pr create \
        --base "main" \
        --head ${branch} \
        --title ${escapeShellArg "Update ${attr}"} \
        --fill-verbose
    fi
    gh pr merge --merge --auto ${branch}
  '';
}
