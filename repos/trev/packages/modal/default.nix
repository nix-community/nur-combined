{
  lib,
  fetchPypi,
  nix-update-script,

  # python packages
  buildPythonPackage,
  setuptools,
  uv-build,
  aiohttp,
  cbor2,
  certifi,
  click,
  grpclib,
  protobuf,
  rich,
  synchronicity,
  toml,
  typer,
  watchfiles,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "modal";
  version = "1.4.0";

  pyproject = true;
  pythonRelaxDeps = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-NAdD9yhP3tFRyE1Uu2/FRfaPk+BkZWNkwZja3J0EId8=";
  };

  build-system = [
    setuptools
    uv-build
  ];

  dependencies = [
    aiohttp
    cbor2
    certifi
    click
    grpclib
    protobuf
    rich
    synchronicity
    toml
    typer
    watchfiles
    typing-extensions
  ];

  postPatch = ''
    sed -i 's/requires = \["setuptools~=.*", "wheel"]/requires = ["setuptools", "wheel"]/' pyproject.toml
    sed -i '/"types-certifi"/d' pyproject.toml
    sed -i '/"types-toml"/d' pyproject.toml
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      pname
    ];
  };

  meta = {
    description = "Convenient, on-demand access to serverless cloud compute";
    mainProgram = "modal";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    homepage = "https://pypi.org/project/modal";
    changelog = "https://pypi.org/project/modal/#history";
    downloadPage = "https://pypi.org/project/modal/#files";
  };
}
