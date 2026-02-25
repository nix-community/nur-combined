{
  fetchFromGitHub,
  lib,
  nix-update-script,
  nvtopPackages,

  # python packages
  buildPythonPackage,
  prometheus-client,
  pydantic,
  setuptools,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "nvtop-exporter";
  version = "0.0.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nvtop-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xjJA6DMvWbBL+Ih2Al2Ybfcpn4yoB49e8FGxs9wYRQ4=";
  };

  build-system = [
    setuptools
    uv-build
  ];

  pythonRelaxDeps = true;
  dependencies = [
    prometheus-client
    pydantic
  ];

  buildInputs = [
    nvtopPackages.full
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${nvtopPackages.full}/bin"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Prometheus exporter for nvtop";
    mainProgram = "nvtop-exporter";
    homepage = "https://github.com/spotdemo4/nvtop-exporter";
    changelog = "https://github.com/spotdemo4/nvtop-exporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
