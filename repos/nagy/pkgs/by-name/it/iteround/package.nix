{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "iteround";
  version = "1.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5r7WcsrX0LbpxayEdFwHTCLHtBomi9OE915igi5S1A0=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "iteround" ];

  meta = with lib; {
    description = "Rounds iterables (arrays, lists, sets, etc) while maintaining the sum of the initial array";
    homepage = "https://pypi.org/project/iteround/";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "iteround";
  };
}
