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
      rev = "6ff03cbaa1835c1511d323ab8752f77f5f579b88";
      hash = "sha256-fS3IjWroivMFQUTa8B+S+L5g+7W7n9Hmi3jrnHPqPO4=";
    };

    cargoHash = "sha256-rq07TK8ilDq3/YdC22uSerxcRUgEJi/0jgamKfGJW7w=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
