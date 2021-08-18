{ lib
, buildPythonPackage
, fetchFromGitHub
, libcst
, mypy-extensions
, django
, pytest-cov
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "monkeytype";
  version = "21.5.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Instagram";
    repo = "MonkeyType";
    rev = "v${version}";
    sha256 = "0mbgayzg10i1z9i0vqcd3fss4adzy5vnqc42bc7nzjbbd584k8q4";
  };

  postPatch = ''
    substituteInPlace pytest.ini --replace \
      "smartcov_paths_hook = tests.util.smartcov_paths_hook" \
      ""
  '';

  propagatedBuildInputs = [
    libcst
    mypy-extensions
  ];

  pythonImportsCheck = [ "monkeytype" ];

  checkInputs = [
    django
    pytest-cov
    pytestCheckHook
  ];

  disabledTests = [
    # Seems to fail on nixpkgs installations
    "test_excludes_site_packages"
  ];

  meta = with lib; {
    homepage = "https://github.com/Instagram/MonkeyType";
    license = licenses.bsd3;
    description = "Generating type annotations from sampled production types";
    maintainers = with maintainers; [ graham33 ];
  };
}
