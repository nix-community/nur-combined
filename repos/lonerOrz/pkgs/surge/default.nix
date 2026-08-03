{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.11.2";

  # https://github.com/surge-downloader/surge
  src = fetchFromGitHub {
    owner = "SurgeDM";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N25JU3uuXr8SGNeoo0JSL0+8rGaYeQ3lWZxn+aXkJIg=";
  };

  vendorHash = "sha256-uZrSOcwfXJ9LwuHi+0wIjPBIsAdULU60GbWrJNV923s=";

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
