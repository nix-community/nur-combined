{ buildPythonPackage
, lib
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "colorzero";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "waveform80";
    repo = "colorzero";
    rev = "release-${version}";
    sha256 = "1nm3zxnzpib74fis6mdc8lb8pvl6275620bc2ixwd1zna9qg77qi";
  };

  propagatedBuildInputs = [];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;  # for nixpkgs < 20.09
  pythonImportsCheck = [ "colorzero" ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "Yet another python color library";
    homepage = "https://colorzero.readthedocs.io/en/latest/";
    license = licenses.bsd3;
    maintainers = [ maintainers.drewrisinger ];
  };
}
