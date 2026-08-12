# Build a landlockconfig configuration granting access to every store path in
# the closure of `rootPaths`.
#
# This is the Landlock counterpart of nixpkgs' `apparmorRulesFromClosure`.
# The result is a single JSON file following the schema printed by
# `llconfig schema`, so it can be passed straight to `llconfig run --json`.
#
# Landlock configurations compose (`llconfig run --json a.json --json b.json`),
# and a ruleset only denies the access rights it handles. The generated file
# therefore only grants access; declare `ruleset.handledAccessFs` here through
# `baseConfig`, or in a configuration composed alongside this one.
{
  lib,
  closureInfo,
  jq,
  runCommand,
}:
{
  # Access rights granted on each store path of the closure. Store paths are
  # read-only, so read and execute is all that makes sense by default.
  allowedAccess ? [ "abi.read_execute" ],
  # Landlock ABI version the generated configuration targets.
  abi ? 5,
  # Configuration the closure rules are composed into, as a Nix attribute set
  # following the landlockconfig JSON schema. Use it to declare a `ruleset`,
  # extra `pathBeneath` rules or `netPort` rules. Its `pathBeneath` entries are
  # kept and the closure rule is appended to them.
  baseConfig ? { },
  # Suffix for the derivation name.
  name ? "",
}:
rootPaths:
runCommand "landlock-closure-config${lib.optionalString (name != "") "-${name}"}.json"
  {
    nativeBuildInputs = [ jq ];
    storePaths = "${closureInfo { inherit rootPaths; }}/store-paths";
    baseConfigJson = builtins.toJSON ({ inherit abi; } // baseConfig);
    passAsFile = [ "baseConfigJson" ];
  }
  ''
    jq --sort-keys \
      --argjson allowedAccess ${lib.escapeShellArg (builtins.toJSON allowedAccess)} \
      --rawfile storePaths "$storePaths" \
      '
        ($storePaths | split("\n") | map(select(. != ""))) as $parent
        | . + {
            pathBeneath: ((.pathBeneath // []) + [
              {
                allowedAccess: $allowedAccess,
                parent: $parent
              }
            ])
          }
      ' "$baseConfigJsonPath" > $out
  ''
