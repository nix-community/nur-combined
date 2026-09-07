{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gengo";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "spenserblack";
    repo = "gengo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BqlXLwDTTP3o28MzKOLv0OWoJpZqEK+dIzD1bn2M57g=";
  };

  cargoHash = "sha256-SI5uEIBiYURPIUA0NG3P3hHSnRczoC+jsWTlBzMrzt4=";

  buildAndTestSubdir = "gengo-bin";

  # these tests analyze the gengo checkout itself via its test/javascript
  # git ref, which the release tarball does not contain
  checkFlags = [
    "--skip=test_color_javascript_repo"
    "--skip=test_color_breakdown_javascript_repo"
    "--skip=test_json_output_on_javascript_repo"
  ];

  meta = {
    description = "Linguist-inspired language classifier with multiple file source handlers";
    homepage = "https://github.com/spenserblack/gengo";
    changelog = "https://github.com/spenserblack/gengo/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "gengo";
  };
})
