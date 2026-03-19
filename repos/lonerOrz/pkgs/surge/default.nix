{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.7.3";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "surge-downloader";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VwLtFPxfkeijNT7b7s0z4VKyM9wp9BnQKxfj4SEb9Bg=";
  };

  vendorHash = "sha256-bnaHnJK/xNAqydy6Vs8ER6o6EXH3ftx0FmdKyo8uDaE=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  # Disable tests that try to create directories in user config paths
  doCheck = false;

  meta = {
    description = "Surge is an open-source download manager";
    homepage = "https://github.com/surge-downloader/surge";
    mainProgram = "surge";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
