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
  uv-build-latest,
}:

buildPythonPackage (final: {
  pname = "nvtop-exporter";
  version = "0.0.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nvtop-exporter";
    tag = "v${final.version}";
    hash = "sha256-89bsdstpFwt5MgW4Bbvt3+kPvzW7CYFCw0d+xtR6Xho=";
  };

  build-system = [
    setuptools
    uv-build-latest
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
      final.pname
    ];
  };

  meta = {
    description = "Prometheus exporter for nvtop";
    mainProgram = "nvtop-exporter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/nvtop-exporter";
    changelog = "https://github.com/spotdemo4/nvtop-exporter/releases/tag/v${final.version}";
  };
})
