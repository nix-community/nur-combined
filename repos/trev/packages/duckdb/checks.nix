{
  lib,
  callPackage,
  runCommand,
  runCommandCC,
}:

let
  extensionNames = lib.pipe (builtins.readDir ./extensions) [
    (lib.filterAttrs (
      name: type:
      type == "regular"
      && lib.hasSuffix ".nix" name
      && !(builtins.elem name [
        "default.nix"
        "generic.nix"
      ])
    ))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
  ];

  toPascalCase =
    name:
    lib.concatMapStrings (
      part:
      lib.toUpper (builtins.substring 0 1 part)
      + builtins.substring 1 (builtins.stringLength part - 1) part
    ) (lib.splitString "-" name);

  mkExtensionCheck =
    name:
    let
      duckdb = callPackage ./default.nix { ${"with${toPascalCase name}"} = true; };
    in
    # loadable extensions share the default core, the wrapper loads each extension
    if duckdb ? unwrapped then
      duckdb
    else
      duckdb.overrideAttrs (
        _finalAttrs: previousAttrs: {
          pname = "${previousAttrs.pname}-extension-${name}";
          doInstallCheck = false;
        }
      );
in

lib.listToAttrs (
  map (name: lib.nameValuePair "duckdb-extension-${name}" (mkExtensionCheck name)) extensionNames
)
// {
  # extensions must be the commits the duckdb release pins, update.sh keeps them in sync
  duckdb-extension-pins =
    let
      duckdb = callPackage ./default.nix { };
      checkPin =
        extension:
        let
          inherit (extension.passthru.duckdbExtension)
            name
            owner
            repo
            rev
            ;
        in
        ''
          check ${
            lib.escapeShellArgs [
              name
              "https://github.com/${owner}/${repo}"
              rev
            ]
          }
        '';
    in
    runCommand "duckdb-extension-pins" { } ''
      status=0
      check() {
        config=${duckdb.src}/.github/config/extensions/$1.cmake
        if [ ! -f "$config" ]; then
          echo "$1: duckdb ${duckdb.version} has no $config" >&2
          status=1
          return
        fi
        url=$(awk '$1 == "GIT_URL" { print $2; exit }' "$config")
        tag=$(awk '$1 == "GIT_TAG" { print $2; exit }' "$config")
        if [ "$url" != "$2" ] || [ "$tag" != "$3" ]; then
          echo "$1: duckdb ${duckdb.version} pins $url@$tag, packaged $2@$3 (run packages/duckdb/update.sh)" >&2
          status=1
        fi
      }

      ${lib.concatMapStrings checkPin (lib.filter lib.isDerivation (lib.attrValues duckdb.extensions))}
      if [ "$status" -ne 0 ]; then
        exit 1
      fi
      touch $out
    '';

  duckdb-link-static =
    let
      duckdb = callPackage ./default.nix { };
    in
    runCommandCC "duckdb-link-static" { } ''
      for archive in ${lib.escapeShellArgs duckdb.link.static.archives}; do
        if [ ! -f "$archive" ]; then
          echo "missing archive: $archive" >&2
          exit 1
        fi
      done

      # repeated, as Go does with CGO_LDFLAGS for each cgo package
      $CC -I${duckdb.link.includeDir} ${./link-check.c} -o link-check \
        ${lib.escapeShellArgs duckdb.link.static.flags} \
        ${lib.escapeShellArgs duckdb.link.static.flags}
      HOME="$(mktemp -d)" ./link-check ${lib.escapeShellArgs duckdb.link.static.extensions}
      touch $out
    '';
}
