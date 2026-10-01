{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:

let
  inherit (pkgs) lib;
  packageSet = import ../default.nix { inherit pkgs; };

  discover = prefix: attrs:
    lib.concatMap (name:
      let
        package = attrs.${name};
        attrPath = lib.concatStringsSep "." (prefix ++ [ name ]);
        updater = package.updateScript or null;
      in
      if lib.isDerivation package then
        lib.optional (updater != null) {
          inherit attrPath;
          name = package.name;
          pname = package.pname or (lib.getName package);
          version = package.version or (lib.getVersion package);
          command = map toString (lib.toList (updater.command or updater));
          updateAttrPath = updater.attrPath or attrPath;
        }
      else if builtins.isAttrs package && (package.recurseForDerivations or false) then
        discover (prefix ++ [ name ]) package
      else
        [ ]
    ) (builtins.attrNames attrs);

  packages = discover [ ] packageSet;
  scriptText = ''
    set -euo pipefail
    cd "$(git rev-parse --show-toplevel)"

    ${lib.concatMapStringsSep "\n" (package: ''
      printf 'Updating %s\n' ${lib.escapeShellArg package.attrPath}
      before="$(git diff --binary HEAD)"
      untracked_before="$(git ls-files --others --exclude-standard)"
      export UPDATE_NIX_NAME=${lib.escapeShellArg package.name}
      export UPDATE_NIX_PNAME=${lib.escapeShellArg package.pname}
      export UPDATE_NIX_OLD_VERSION=${lib.escapeShellArg package.version}
      export UPDATE_NIX_ATTR_PATH=${lib.escapeShellArg package.updateAttrPath}
      ${lib.escapeShellArgs package.command}
      if [[ "$before" != "$(git diff --binary HEAD)" ]] || [[ "$untracked_before" != "$(git ls-files --others --exclude-standard)" ]]; then
        printf 'Building %s\n' ${lib.escapeShellArg package.attrPath}
        nix-build . --no-out-link -A ${lib.escapeShellArg "${package.attrPath}.all"}
      fi
    '') packages}

    git diff --stat
    git diff
  '';
in
{
  inherit packages scriptText;
  script = pkgs.writeShellScript "update-packages" scriptText;
}
