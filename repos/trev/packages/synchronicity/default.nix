{
  lib,
  fetchPypi,
  nix-update-script,

  # python packages
  buildPythonPackage,
  hatchling,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "synchronicity";
  version = "0.11.1";

  pyproject = true;
  pythonRelaxDeps = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-NijfmrNL176JtykQQRSEHGJhLF1exDt29LeyQxhewag=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      pname
    ];
  };

  meta = {
    description = "Lets you interoperate with asynchronous Python APIs";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    homepage = "https://pypi.org/project/synchronicity";
    changelog = "https://pypi.org/project/synchronicity/#history";
    downloadPage = "https://pypi.org/project/synchronicity/#files";
  };
}
