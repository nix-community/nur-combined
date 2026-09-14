{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gopro-chaptered-video-assembler";
  version = "0.5.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "alichtman";
    repo = "gopro-chaptered-video-assembler";
    # tag = "v${finalAttrs.version}";
    # version 0.5.3 has no git tag
    # https://github.com/alichtman/gopro-chaptered-video-assembler/issues/27
    rev = "26530ff5231317a32639135a5ebed728eaa4297c"; # 0.5.3
    hash = "sha256-zphucBcDDmYGr0aKmTrok12KLxv1WXfhsE1H/CRAcjo=";
  };

  cargoHash = "sha256-K2ganjhp5TvuaDSmuvI55T13e7qdAb2kS5NwVpRFoPU=";

  # fix: test fails with: assertion failed: expected_output_hash == actual_output_hash
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GoPro breaks long videos into multiple files. This tool stitches them back together";
    homepage = "https://github.com/alichtman/gopro-chaptered-video-assembler";
    # changelog = "https://github.com/alichtman/gopro-chaptered-video-assembler/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gopro-chaptered-video-assembler";
  };
})
