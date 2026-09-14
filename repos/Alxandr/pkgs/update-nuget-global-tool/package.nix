{
  lib,
  curl,
  jq,
  nix,
  nix-update,
  writeShellApplication,
}:

(writeShellApplication {
  name = "update-nuget-global-tool";
  runtimeInputs = [
    curl
    jq
    nix
    nix-update
  ];

  text = ''
    attr=''${UPDATE_NIX_ATTR_PATH:?}

    nixeval() {
      nix --extra-experimental-features nix-command eval --json --impure -f . "$1" | jq -r .
    }

    nugetName=$(nixeval "$attr.nupkg.pname")

    # Always skip prerelease versions for now.
    version=$(curl -fsSL "https://api.nuget.org/v3-flatcontainer/$nugetName/index.json" |
      jq -er '.versions | last(.[] | select(match("^[0-9]+\\.[0-9]+\\.[0-9]+$")))')

    if [[ $version == $(nixeval "$attr.version") ]]; then
      echo "$attr is already version $version"
      exit 0
    fi

    fileName=$(
      nix --extra-experimental-features nix-command eval \
        --raw \
        --impure \
        --expr 'let attr = builtins.getEnv "UPDATE_NIX_ATTR_PATH"; repo = import ./. {}; pkg = builtins.getAttr attr repo; in (builtins.unsafeGetAttrPos "nugetHash" pkg).file'
    )

    nix-update "$attr" \
      --version "$version" \
      --override-filename "$fileName" \
      --subpackage nupkg
  '';

}).overrideAttrs
  (prev: {
    meta = (prev.meta or { }) // {
      description = "Script to update a NuGet global tool's nix expressions";
      homepage = "https://github.com/Alxandr/nur/tree/master/pkgs/update-nuget-global-tool";
      license = lib.licenses.mit;
    };
  })
