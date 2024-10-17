{
  lib,
  stdenvNoCC,
  cacert,
  deno,
  git,
  tree,
  jq,
}:

{
  name ? "deno-deps",
  src ? null,
  srcs ? [ ],
  patches ? [ ],
  sourceRoot ? "",
  hash ? "",
  sha256 ? "",
  entrypoint ? "",
  lockfileLocation ? "lock.json",
  ...
}@args:

let
  hash_ =
    if hash != "" then
      {
        outputHashAlgo = null;
        outputHash = hash;
      }
    else if sha256 != "" then
      {
        outputHashAlgo = "sha256";
        outputHash = sha256;
      }
    else
      throw "fetchDenoTarball requires a hash for ${name}";
in
stdenvNoCC.mkDerivation (
  {
    name = "${name}-vendor.tar.gz";
    nativeBuildInputs = [
      cacert
      deno
      jq
      git
    ];

    phases = "unpackPhase patchPhase buildPhase installPhase";

    buildPhase = ''
      # Ensure deterministic Deno dependency builds
      export SOURCE_DATE_EPOCH=1

      export DENO_DIR=$name

      if [[ ! -f "${lockfileLocation}" ]]; then
        echo "lockfile doesnt exist, generating..."
        if [[ ! -f "${entrypoint}" ]]; then
            echo
            echo "ERROR: The entrypoint file doesn't exist"
            echo

            exit 1
        fi
        deno cache --lock="${lockfileLocation}" --lock-write "${entrypoint}"
      else
        echo "lockfile found"
        deno cache --lock="${lockfileLocation}" --reload "${entrypoint}"
      fi
      echo "delete buildinfo and strip non-reproducable metadata"
      rm -rf $DENO_DIR/gen
      find . -name '*.metadata.json' -exec sh -c "cat {} | jq -c '{ headers: { }, now: { secs_since_epoch: 0, nanos_since_epoch: 0 }, url: .url }' | tee {}" \;
      cp ${lockfileLocation} $name/lockfile.json
    '';

    # Build a reproducible tar, per instructions at https://reproducible-builds.org/docs/archives/
    installPhase = ''
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
          --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          -czf $out $name
    '';

    inherit (hash_) outputHashAlgo outputHash;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
  }
  // (builtins.removeAttrs args [
    "name"
    "sha256"
  ])
)
