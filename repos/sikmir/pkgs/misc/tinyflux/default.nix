{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tinyflux";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "citrusvanilla";
    repo = "tinyflux";
    tag = "v${version}";
    hash = "sha256-WgNkYFWZvZJ8MYMqfnqXH8YgjzRemMxAkyN9On+5PQI=";
  };

  postPatch = ''
    echo ${version} > version.txt
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "The tiny time series database";
    homepage = "https://github.com/citrusvanilla/tinyflux";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
