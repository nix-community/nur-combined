{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module (finalAttrs: {
  pname = "ghoten";
  version = "1.12.5";

  src = fetchFromGitHub {
    owner = "vmvarela";
    repo = "ghoten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FJcQ1DDCDjf8Ly/ClOUBLxHK+Ti8gCuaeU8Wwk8T/Ao=";
  };

  vendorHash = "sha256-BySnJKMoUmvotms8TFhMUBz+pTIxsdSXqldy2lPYJtI=";
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
