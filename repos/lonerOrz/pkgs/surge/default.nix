{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.1.1";

  # https://github.com/junaid2005p/surge
  src = fetchFromGitHub {
    owner = "junaid2005p";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Utm4D63vLb/kTxem9RLQdb5UR5OZm52+r+i/qz1GVh0=";
  };

  vendorHash = "sha256-SO2mOZZ6We3XXtpnaIvVchqFy/x07k+tvJ25sTxQxXU=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  # Disable tests that try to create directories in user config paths
  doCheck = false;

  meta = {
    description = "Surge is an open-source download manager";
    homepage = "https://github.com/junaid2005p/surge";
    mainProgram = "surge";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
