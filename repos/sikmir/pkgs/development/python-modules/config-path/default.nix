{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "config-path";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "barry-scott";
    repo = "config-path";
    tag = version;
    hash = "sha256-W3qsCGYejM5J2FIYGJ5An2YCfuqQBtx6q3JCUxQAWUg=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  meta = {
    description = "Python library to work with paths to config folders and files in an OS independent way";
    homepage = "https://github.com/barry-scott/config-path";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
