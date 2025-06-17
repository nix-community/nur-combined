{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oli";
  version = "0.53.3";

  # Cannot use `fetchFromGitHub` because `bin` is marked as `export-ignore`.
  src = fetchgit {
    url = "https://github.com/apache/opendal.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3w0tp8UGkfYQ+6HpKMKTQr0h86wI4z0N/ILtq19dqSM=";
  };
  sourceRoot = "${finalAttrs.src.name}/bin/oli";

  useFetchCargoVendor = true;
  cargoHash = "sha256-NQQPj8w4eoic5fn/VSVe5OOGoj07jUXcTSFZN/q4Zoc=";

  meta = {
    description = "Unified and user-friendly way to manipulate data stored in various storage service";
    homepage = "https://opendal.apache.org/apps/oli/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "oli";
  };
})
