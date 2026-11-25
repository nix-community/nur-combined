{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.13.0";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "SurgeDM";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CoAkTKhnQXiq4x4xYajgx3dTw9/dxOzwBgRMXlOBv54=";
  };

  vendorHash = "sha256-STf2NB5HkWBmTwJSotuWgvQY3zS8vAE0qRRjO/haTsg=";

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
