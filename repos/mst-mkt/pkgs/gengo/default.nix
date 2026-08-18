{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gengo";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "spenserblack";
    repo = "gengo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/1HUfYltG4WE3HKU5MxW+t4TL63ntAfb8dcs1yTPeoo=";
  };

  cargoHash = "sha256-gjSEkcJyw5bD5z/8Om5R32++KXEP/nUjRpgShfi0xVo=";

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
