{ fetchFromGitHub, python3Packages, nmigen }:

# TODO: needs cleanup and meta
python3Packages.buildPythonApplication rec {
  pname = "nmigen-boards";
  version = "0.1rc1";
  nativeBuildInputs = [
    python3Packages.setuptools_scm
  ];
  prePatch = ''
    substituteInPlace setup.py --replace "setuptools_scm" ""
  '';
  propagatedBuildInputs = [
    nmigen
  ];
  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "nmigen-boards";
    rev = "5ce5b04607cf41cd00c30837edce385ce74c1cf1";
    sha256 = "1yj4m182ywb5dx67m2irhfqr6sagdd4yxmbghfzvyy4b5ibj1934";
  };
  # give a hint to setuptools_scm on package version
  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';
}
