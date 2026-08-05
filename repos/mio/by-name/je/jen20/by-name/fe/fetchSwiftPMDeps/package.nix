# Fetches a package based on its metadata from `Package.resolved`
{
  lib,
  cacert,
  jq,
  nix-prefetch-git,
  nix,
  stdenvNoCC,
}:

{
  name ? if args ? pname && args ? version then "${args.pname}-${args.version}" else "swiftpm-deps",
  hash ? (throw "fetchSwiftPMDeps requires a `hash` value to be set for ${name}"),
  nativeBuildInputs ? [ ],
  ...
}@args:

let
  removedArgs = [
    "name"
    "pname"
    "version"
    "nativeBuildInputs"
    "hash"
  ];
in

stdenvNoCC.mkDerivation (
  {
    name = "${name}-vendor";

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;

    strictDeps = true;

    nativeBuildInputs = [
      cacert
      jq
      nix-prefetch-git
    ]
    ++ nativeBuildInputs;

    buildPhase = ''
      runHook preBuild

      resolved=$PWD/Package.resolved

      # Convert version 1 to version 2 because its pins `schema` differs.
      # Version 3 has the same pins schema, so it is already compatible.
      if [ "$(jq --raw-output '.version' < "$resolved")" = "1" ]; then
        resolved_tmp=$(mktemp)
        trap "rm -- '$resolved_tmp'" EXIT
        jq '
           {
               pins: [
                   .object.pins[] | {
                       identity: .package,
                       kind: "remoteSourceControl",
                       location: .repositoryURL,
                       state: .state
                   }
               ],
               version: 2
           }
        ' < "$resolved" > "$resolved_tmp"
        resolved=$resolved_tmp
      fi

      if [ -n "$(jq --raw-output '.pins[] | select(.kind != "remoteSourceControl")' < "$resolved")" ]; then
        echo "Only Git-based dependencies are supported by fetchSwiftPMDeps"
        exit 1
      fi

      mkdir -p "$out"

      jq --raw-output0 '.pins[] | select(.kind == "remoteSourceControl")' < "$resolved" | while IFS= read -d "" pin; do
        url=$(jq --raw-output '.location' <<< "$pin")
        name=$(basename "$url" .git)
        rev=$(jq --raw-output '.state.revision' <<< "$pin")
        nix-prefetch-git --builder --quiet --fetch-submodules --url "$url" --rev "$rev" --out "$out/Packages/$name"
      done

      # SwiftPM uses workspace-state.json to determine whether it needs to fetch dependencies.
      # Generate it to prevent that from happening.
      jq --compact-output --sort-keys '
          {
              "object": {
                  "artifacts": [ ],
                  "dependencies": [ .pins[] |
                      {
                          "basedOn": {
                              "basedOn": null,
                              "packageRef": {
                                  "identity": .identity,
                                  "kind": .kind,
                                  "location": .location,
                                  "name": .location | sub("\\.git$"; "") | split("/")[-1]
                              },
                              "state": {
                                  "checkoutState": .state,
                                  "name": "sourceControlCheckout"
                              },
                              "subpath": .location | sub("\\.git$"; "") | split("/")[-1]
                          },
                          "packageRef": {
                              "identity": .identity,
                              "kind": .kind,
                              "location": .location,
                              "name": .location | sub("\\.git$"; "") | split("/")[-1]
                          },
                          "state": {
                              "name": "edited",
                              "path": null
                          },
                          "subpath": .location | sub("\\.git$"; "") | split("/")[-1]
                      }
                  ],
                  "prebuilts": [ ]
              },
              "version": 7
          }
      ' < "$resolved" > "$out/workspace-state.json"

      runHook postBuild
    '';

    dontConfigure = true;
    dontInstall = true;
    dontFixup = true;

    outputHash = hash;
    outputHashAlgo = if hash == "" then "sha256" else null;
    outputHashMode = "recursive";

    __structuredAttrs = true;
  }
  // builtins.removeAttrs args removedArgs
)
