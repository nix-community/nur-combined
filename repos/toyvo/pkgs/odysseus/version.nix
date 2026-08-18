# Extract the app version from src/constants.py at Nix evaluation time.
#
# The single source of truth for the version is APP_VERSION in
# src/constants.py (the value the app serves at /version). This parses it so
# the Nix package version can't drift from the app's reported version.
#
# Falls back to hardcoded version if source is not available (e.g., NUR eval
# with restrict-eval, or when the source hasn't been fetched yet).
{ src }:
let
  # Hardcoded fallback version - update this when the package updates
  fallbackVersion = "2026.8.18";

  versionFromSourceResult = builtins.tryEval (
    let
      constantsContent = builtins.readFile (src + "/src/constants.py");
      versionLine = builtins.head (
        builtins.filter (line: builtins.match "APP_VERSION[[:space:]]*=.*" line != null) (
          builtins.filter (line: line != "") (
            builtins.filter (l: builtins.typeOf l == "string") (builtins.split "\n" constantsContent)
          )
        )
      );
    in
    builtins.head (
      builtins.match ''APP_VERSION[[:space:]]*=[[:space:]]*"([^"]+)".*'' versionLine
    )
  );
in
# Use version from source if available, otherwise fall back to hardcoded
if versionFromSourceResult.success then versionFromSourceResult.value else fallbackVersion
