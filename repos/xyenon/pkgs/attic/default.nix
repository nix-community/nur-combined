{
  attic-client,
  fetchFromGitHub,
  rustPlatform,
  ...
}@args:

let
  overrideArgs = builtins.removeAttrs args [
    "attic-client"
    "fetchFromGitHub"
    "rustPlatform"
  ];
in
(attic-client.override overrideArgs).overrideAttrs (
  finalAttrs: _prevAttrs: {
    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "attic";
      rev = "b30f058edb4d1973a9ef38137c89d15ff36d88a0";
      hash = "sha256-Gv3kEwcrindJmsoJGkhq1PkQS8Fzq18MyPQ+aStTFgE=";
    };

    cargoHash = "sha256-VCw5eRoa9ftghI0yQPTj72GR5Cnfq7B7VwddqjOrTag=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
