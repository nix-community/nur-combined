{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tatuin";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "panter-dsd";
    repo = "tatuin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TPIjVpIFgBdZvPdmC1IyPyAjRP2Zq4Tx2HPAPrik7Ok=";
  };

  cargoHash = "sha256-MIWm84Dmhy71glhAQLEIX69IWQHePx4nY9TT2O9E7Fw=";

  nativeBuildInputs = [ perl ];

  meta = {
    description = "Task Aggregator TUI for N providers";
    homepage = "https://github.com/panter-dsd/tatuin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tatuin";
  };
})
