{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyarrow_ops";
  version = "0-unstable-2022-01-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TomScheffers";
    repo = "pyarrow_ops";
    rev = "d8ee38e47ed064a5e8179d53086ac5ed67c44e6a";
    hash = "sha256-g3dFAviGSafK2mLWgF4zhXHW8ffBnoQheeC+whAOLRY=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = with python3Packages; [ cython ];

  propagatedBuildInputs = with python3Packages; [
    numpy
    pyarrow
  ];

  meta = {
    description = "Convenient pyarrow operations following the Pandas API";
    homepage = "https://github.com/TomScheffers/pyarrow_ops";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
