{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  numpy,
}:
buildPythonPackage (finalAttrs: {
  pname = "kaldiio";
  version = "2.18.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nttcslab-sp";
    repo = "kaldiio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CssVH+Oxsw+it1mHdBhGIEYxoZ3OSr09eoankSjcxR0=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    numpy
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail '"pytest-runner"' ""
  '';

  pythonImportsCheck = [ "kaldiio" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/nttcslab-sp/kaldiio/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Pure python module for reading and writing kaldi ark files";
    homepage = "https://github.com/nttcslab-sp/kaldiio";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})
