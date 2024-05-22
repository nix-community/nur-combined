{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tinyflux";
  version = "0.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "citrusvanilla";
    repo = "tinyflux";
    rev = "v${version}";
    hash = "sha256-mDbkKTFln0fYJW0DhLxdQu8ubjsjzJtJW9a+AD1NOU8=";
  };

  postPatch = ''
    echo ${version} > version.txt
  '';

  propagatedBuildInputs = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "The tiny time series database";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
