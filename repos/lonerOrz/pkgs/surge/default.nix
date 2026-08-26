{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.12.1";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "SurgeDM";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cUJwt4gRdlQvMnrEvYG7JZe/2oz4cN9k35TEur13Sks=";
  };

  vendorHash = "sha256-Ei2i7dQ9s42Gg6f2iLABbTG7OQspjHoRnqIhkfcNvFo=";

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
