# Builds a vendor directory from a gomod2nix.toml, fetching each module in a
# fixed-output derivation like gomod2nix does, so its hashes can be reused.
#
# vendor/modules.txt is written like `go mod vendor` would, from the main
# module's go.mod. Without the main module's sources it doesn't know which
# packages are imported, so every package of the modules is listed.
#
# go.mod and local replacements are read from the source at evaluation time, so
# the vendor directory only changes with them, not with the rest of the source.
{
  cacert,
  gitMinimal,
  jq,
  lib,
  runCommand,
  stdenvNoCC,
}:

{
  pname,
  go,
  # path to gomod2nix.toml
  modules,
  # directory of the main module's go.mod
  modDir,
}:

let
  manifest = lib.importTOML modules;

  goMod = builtins.readFile "${modDir}/go.mod";

  # replacements with local paths, which aren't in gomod2nix.toml
  localPaths = lib.unique (
    lib.concatMap (
      line:
      let
        match = builtins.match "[[:space:]]*(replace[[:space:]]+)?[^[:space:]]+([[:space:]]+v[^[:space:]]+)?[[:space:]]+=>[[:space:]]+((\\.\\.?)?/[^[:space:]]*|\\.\\.?)[[:space:]]*(//.*)?" line;
      in
      lib.optional (match != null) (builtins.elemAt match 2)
    ) (lib.splitString "\n" goMod)
  );

  fetchGoModule =
    {
      goPackagePath,
      version,
      hash,
    }:
    stdenvNoCC.mkDerivation {
      # named like gomod2nix's, so the store paths are shared
      name = "${baseNameOf goPackagePath}_${version}";
      inherit goPackagePath version;

      nativeBuildInputs = [
        cacert
        gitMinimal
        go
        jq
      ];

      buildCommand = ''
        export HOME="$TMPDIR" GOPATH="$TMPDIR/go" GOTOOLCHAIN=local

        go mod download -json "$goPackagePath@$version" > download.json \
          || { jq -r '.Error' download.json >&2; exit 1; }

        cp -r "$(jq -r '.Dir' download.json)" $out
        chmod -R u+w $out
        find $out -iname .ds_store -exec rm -rf {} +
      '';

      outputHashMode = "recursive";
      outputHash = hash;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [ "GOPROXY" ];
    };

  # without the main module, when gomod2nix.toml was generated for a remote package
  mod = removeAttrs manifest.mod (lib.optional (manifest ? goPackagePath) manifest.goPackagePath);

  sources = lib.mapAttrs (
    path: module:
    fetchGoModule {
      goPackagePath = module.replaced or path;
      inherit (module) version hash;
    }
  ) mod;
in

assert lib.assertMsg (manifest.schema or null == 3)
  "mkGoModule: ${toString modules} has an unsupported schema (only schema 3 is supported), regenerate it with a recent gomod2nix";

runCommand "${pname}-go-modules"
  {
    nativeBuildInputs = [
      go
      jq
    ];

    inherit goMod;
    modules = builtins.toJSON {
      inherit mod sources;
      local = lib.genAttrs localPaths (
        path:
        builtins.path {
          name = "source";
          path = "${modDir}/${path}";
        }
      );
    };
    passAsFile = [
      "goMod"
      "modules"
    ];

    passthru = {
      inherit sources;
    };
  }
  ''
    export HOME="$TMPDIR" GOTOOLCHAIN=local

    atLeast() {
      [ -n "$2" ] && [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$1" ]
    }

    go mod edit -json "$goModPath" > go.mod.json
    mainGo=$(jq -r '.Go // ""' go.mod.json)

    # `go mod vendor` annotates explicit requirements and lists all replacements
    # since go 1.14, and annotates go versions since go 1.17
    explicit=
    goVersions=
    if atLeast 1.14 "$mainGo"; then explicit=1; fi
    if atLeast 1.17 "$mainGo"; then goVersions=1; fi

    # the required modules, and the ones only in gomod2nix.toml for go < 1.17,
    # with their replacements and sources
    jq -r --slurpfile m "$modulesPath" '
      $m[0] as $m
      | (.Replace // []) as $replace
      | [(.Require // [])[] | {path: .Path, version: .Version, explicit: true}] as $require
      | ($require + [
          $m.mod | to_entries[]
          | select(.key as $path | all($require[]; .path != $path))
          | {path: .key, version: .value.version, explicit: false, replaced: .value.replaced}
        ])
      | sort_by(.path, .version)[]
      | . as $module
      | ((first(
          ($replace[] | select(.Old.Path == $module.path and .Old.Version == $module.version)),
          ($replace[] | select(.Old.Path == $module.path and .Old.Version == null))
        ) | .New) // null) as $new
      | (if $new != null and $new.Version == null then
          $m.local[$new.Path] // error("mkGoModule: \($module.path) is replaced by \($new.Path), which is not a local directory in the source")
        else
          $m.mod[$module.path] as $entry
          | ($new.Version // $module.version) as $version
          | if $entry == null then
              error("mkGoModule: \($module.path)@\($version) is missing from gomod2nix.toml, regenerate it with `gomod2nix generate`")
            elif $entry.version != $version then
              error("mkGoModule: gomod2nix.toml has \($module.path)@\($entry.version) instead of \($version), regenerate it with `gomod2nix generate`")
            else
              $m.sources[$module.path]
            end
        end) as $src
      | [$module.path, ($module.version // ""), (if $module.explicit then "1" else "" end), ($new.Path // ""), ($new.Version // ""), $src, ($module.replaced // "")]
      | join("\u001f")
    ' go.mod.json > vendored

    mkdir -p $out
    : > $out/modules.txt
    while IFS=$'\x1f' read -r path version isExplicit newPath newVersion src replaced; do
      mkdir -p "$out/$path"
      cp -r --no-preserve=mode "$src"/. "$out/$path"

      # before go 1.17 the modules that aren't required can be imported without
      # being listed, only listing the module of the original path is supported
      if [ -z "$isExplicit" ] && [ -n "$replaced" ]; then
        continue
      fi

      line="# $path $version"
      if [ -n "$newPath" ]; then
        line+=" => $newPath''${newVersion:+ $newVersion}"
      fi
      echo "$line" >> $out/modules.txt

      goVersion=
      if [ -n "$goVersions" ] && [ -f "$src/go.mod" ]; then
        goVersion=$(go mod edit -json "$src/go.mod" | jq -r '.Go // ""')
      fi
      if [ -n "$explicit" ] && [ -n "$isExplicit" ]; then
        echo "## explicit''${goVersion:+; go $goVersion}" >> $out/modules.txt
      elif [ -n "$goVersion" ]; then
        echo "## go $goVersion" >> $out/modules.txt
      fi

      # directories with go files, skipping the ones go ignores and nested modules
      (
        cd "$src"
        find . -mindepth 1 -type d \( -name '.*' -o -name '_*' -o -name testdata -o -name vendor -o -exec test -e '{}/go.mod' \; \) -prune \
          -o -type f -name '*.go' ! -name '*_test.go' -printf '%h\n'
      ) | LC_ALL=C sort -u | while read -r dir; do
        echo "$path''${dir#.}"
      done >> $out/modules.txt
    done < vendored

    # replacements that weren't written for a module, including wildcard ones
    if [ -n "$explicit" ]; then
      jq -r '
        [(.Require // [])[] | {Path, Version}] as $require
        | (.Replace // [])[]
        | select(.Old as $old | all($require[]; . != $old))
        | "# \(.Old.Path)\(.Old.Version // "" | if . != "" then " " + . else "" end) => \(.New.Path)\(.New.Version // "" | if . != "" then " " + . else "" end)"
      ' go.mod.json >> $out/modules.txt
    fi
  ''
