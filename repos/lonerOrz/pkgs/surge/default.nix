{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.7.7";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "SurgeDM";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YuNQlpdigs44Xrl0P7TKmSN0FKoxwZUZTGWuF3yDbHs=";
  };

  vendorHash = "sha256-dM0MpXdvxn7RH4USOyeIOVsdoyE4VUw+U44Qc9IkK5s=";

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
