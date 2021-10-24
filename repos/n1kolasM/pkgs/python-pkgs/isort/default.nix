{ lib, buildPythonPackage, fetchPypi, setuptools, mock, pytest
, withPipfile ? false, pipreqs ? null, tomlkit ? null, requirementslib ? null
, withPyproject ? false, toml ? null
, withRequirements ? false, pip-api ? null
}:
assert withPipfile -> pipreqs != null && tomlkit != null && requirementslib != null;
assert withPyproject -> toml != null;
assert withRequirements -> pipreqs != null && pip-api != null;
let
  skipTests = [ "test_requirements_finder" "test_pipfile_finder" ];
  testOpts = lib.concatMapStringsSep " " (t: "--deselect test_isort.py::${t}") skipTests;
in buildPythonPackage rec {
  pname = "isort";
  version = "4.3.21"; # Note 4.x is the last version that supports Python2

  src = fetchPypi {
    inherit pname version;
    sha256 = "54da7e92468955c4fceacd0c86bd0ec997b0e1ee80d97f67c35a78b719dccab1";
  };

  propagatedBuildInputs = [
    setuptools
  ] ++ lib.optional (withPipfile || withRequirements) pipreqs
    ++ lib.optionals withPipfile [ tomlkit requirementslib ]
    ++ lib.optional withPyproject toml
    ++ lib.optional withRequirements pip-api;

  checkInputs = [ mock pytest ];

  checkPhase = ''
    # isort excludes paths that contain /build/, so test fixtures don't work
    # with TMPDIR=/build/
    PATH=$out/bin:$PATH TMPDIR=/tmp/ pytest ${testOpts}

    # Confirm that the produced executable script is wrapped correctly and runs
    # OK, by launching it in a subshell without PYTHONPATH
    (
      unset PYTHONPATH
      echo "Testing that `isort --version-number` returns OK..."
      $out/bin/isort --version-number
    )
  '';

  meta = with lib; {
    description = "A Python utility / library to sort Python imports";
    homepage = https://github.com/timothycrosley/isort;
    license = licenses.mit;
  };
}

