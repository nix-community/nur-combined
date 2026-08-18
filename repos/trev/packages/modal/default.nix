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
  version = "1.5.4";

  pyproject = true;
  pythonRelaxDeps = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1hG7R/wHEX9dGU9/mpwKukU3VzoTY0m75FxWlOZLypI=";
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
