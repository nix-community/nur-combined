{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "pipfile";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "pipfile";
    rev = "v${version}";
    hash = "sha256-GsDhxnvBvjJGQWk25cS9+HqLQ9YVSxujeX2iGivYl6Q=";
  };

  propagatedBuildInputs = with python3Packages; [ toml ];

  doCheck = false;
  pythonImportsCheck = [ "pipfile" ];

  meta = with lib; {
    description = "Pipfile: the replacement for requirements.txt";
    inherit (src.meta) homepage;
    license = with licenses; [ asl20 bsd2 ];
    maintainers = [ maintainers.sikmir ];
  };
}
