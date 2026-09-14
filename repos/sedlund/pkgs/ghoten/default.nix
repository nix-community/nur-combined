{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module (finalAttrs: {
  pname = "ghoten";
  version = "1.13.5";

  src = fetchFromGitHub {
    owner = "vmvarela";
    repo = "ghoten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BNuSpD5ramaoNU1bXVJpVJK7FYSKYKv5RmU+9D2cMcU=";
  };

  vendorHash = "sha256-Tatv/tvJPWCM2YTr3u95EgX59Bo8S71e2Gcy2t+YVHI=";
  subPackages = [ "cmd/ghoten" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/vmvarela/ghoten/version.dev=no"
    "-X github.com/vmvarela/ghoten/version.versionOverride=${finalAttrs.version}"
  ];

  meta = {
    description = "OpenTofu fork with ORAS backend and additional integrations";
    homepage = "https://github.com/vmvarela/ghoten";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ sedlund ];
    mainProgram = "ghoten";
    platforms = lib.platforms.unix;
  };
})
