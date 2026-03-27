{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module (finalAttrs: {
  pname = "ghoten";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "vmvarela";
    repo = "ghoten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9JVtXyx2TJIjmDr64nseqIeLrOTXWzKvvElkeye/67g=";
  };

  vendorHash = "sha256-/rjx6/NofP60Gro/n62sCSboKh133LG5ArlP+U2O+dw=";
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
