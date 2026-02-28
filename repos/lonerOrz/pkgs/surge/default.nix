{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.6.10";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "surge-downloader";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XSoMLDfoQ1igjaKo1kgFT4LVzGGgOi8e+b9GauWIRYI=";
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
    homepage = "https://github.com/surge-downloader/surge";
    mainProgram = "surge";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
