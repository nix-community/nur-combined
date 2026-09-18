{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tatuin";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "panter-dsd";
    repo = "tatuin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SkliqxaT39gO1Xd2AKH2cHrpxseqRbTNSRcA3z1WAzA=";
  };

  cargoHash = "sha256-AiWaot+plToiptsOl2OcuGbST1ciWKOjd7Gk2qARYvI=";

  nativeBuildInputs = [ perl ];

  meta = {
    description = "Task Aggregator TUI for N providers";
    homepage = "https://github.com/panter-dsd/tatuin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tatuin";
  };
})
