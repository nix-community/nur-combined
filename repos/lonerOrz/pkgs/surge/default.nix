{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.5.5";

  # https://github.com/junaid2005p/surge
  src = fetchFromGitHub {
    owner = "junaid2005p";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IpDPJYPDeUHxgtbqgUCgdTg+h98H3xhn5gN4T+D0YjU=";
  };

  vendorHash = "sha256-IGVt/HanZHglYSZ8WASrzqvTZZtK/bJpJzXNVqSqUfE=";

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
