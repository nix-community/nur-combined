{ lib, fetchFromGitHub, python3Packages, setuptools, setuptools_scm, numba
, scipy, openssl, installShellFiles, pillow }:

python3Packages.buildPythonPackage rec {
  pname = "PyMatting";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1k6r9ddrdddmv9f12l3lhcq03z8m2jdmhn8dddx4l0hpdjqnkr7m";
  };

  pythonImportsCheck = [ "pymatting" "pymatting_aot" ];

  nativeBuildInputs = [ setuptools_scm installShellFiles ];

  propagatedBuildInputs = [ pillow numba scipy openssl ];

  doCheck = false;

  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
