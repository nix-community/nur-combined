{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  numpy,
}:
buildPythonPackage rec {
  inherit (sources.kaldiio) pname version src;

  propagatedBuildInputs = [
    numpy
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail '"pytest-runner"' ""
  '';

  pythonImportsCheck = [ "kaldiio" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Pure python module for reading and writing kaldi ark files";
    homepage = "https://github.com/nttcslab-sp/kaldiio";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
