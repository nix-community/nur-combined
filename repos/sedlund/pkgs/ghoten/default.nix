{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module (finalAttrs: {
  pname = "ghoten";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner = "vmvarela";
    repo = "ghoten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-//4POTuv60EfUBh47LgIATZbDAfFf883dEYjzuxuInM=";
  };

  vendorHash = "sha256-rWhdjSbzghoz/DDehgA5O/RRlF8fHoX6hrB1NmIyFEE=";
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
