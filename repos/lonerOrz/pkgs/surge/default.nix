{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.8.0";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "SurgeDM";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M6XlKd9JFVg7/01M5l7fjsi7HrcL+Smo+fQrhFRI7B0=";
  };

  vendorHash = "sha256-pbKnMrfY/abu/Mj0HhDhTUSOlWl82kgIM0zXwtlQw/U=";

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
