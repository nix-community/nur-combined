{
  attic-client,
  fetchFromGitHub,
  rustPlatform,
}:

attic-client.overrideAttrs (
  finalAttrs: _prevAttrs: {
    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "attic";
      rev = "126f76c382c7accd270b44adebf2fcb6de6c4892";
      hash = "sha256-mlZfpK1iWINSAGJTh6sW0FoUusOujaiZuvyzaD3ZWuw=";
    };

    cargoHash = "sha256-VCw5eRoa9ftghI0yQPTj72GR5Cnfq7B7VwddqjOrTag=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };
  }
)
