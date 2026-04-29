{
  writeShellScriptBin,
  jq,
  lib,
  commands,
  preScript ? "",
}:

let
  inherit (lib)
    mapAttrsToList
    toUpper
    concatStringsSep
    replaceStrings
    attrNames
    ;

  # Normalize key to be safe for Bash variables and jq arguments
  # e.g., "short-rev" -> "SHORT_REV"
  safeKey = key: replaceStrings [ "-" "." ] [ "_" "_" ] (toUpper key);

  # Generate shell assignment lines for each command
  varLines = mapAttrsToList (key: cmd: ''
    _VAL_${safeKey key}=$(${cmd})
  '') commands;

  # Generate jq --arg flags for each variable
  jqArgLines = mapAttrsToList (key: _: ''--arg ${safeKey key} "$_VAL_${safeKey key}"'') commands;

  # Construct the jq object filter
  # Final format: { "version": $VERSION, "rev": $REV }
  jqFilter =
    "{ "
    + (concatStringsSep ", " (map (key: ''"${key}": $'' + (safeKey key)) (attrNames commands)))
    + " }";
in
writeShellScriptBin "mk-json" ''
  set -euo pipefail

  # Execute pre-processing script (e.g., fetch data into variables)
  ${preScript}

  # Execute commands to capture metadata into shell variables
  ${concatStringsSep "\n  " varLines}

  # Construct and output final JSON using jq
  ${jq}/bin/jq -n \
    ${concatStringsSep " \\\n    " jqArgLines} \
    '${jqFilter}'
''
