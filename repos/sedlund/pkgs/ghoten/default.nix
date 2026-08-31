{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module (finalAttrs: {
  pname = "ghoten";
  version = "1.13.4";

  src = fetchFromGitHub {
    owner = "vmvarela";
    repo = "ghoten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NYfAmGrv1JRNi0EZH4mVrnVMX1gt66zksgwPW639llA=";
  };

  vendorHash = "sha256-Ia71gEinMzPyLDiI1r6QKf2tLojUi0lqTbkM3uGzrx0=";
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
