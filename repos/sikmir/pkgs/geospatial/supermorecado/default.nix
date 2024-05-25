{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "supermorecado";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "supermorecado";
    rev = version;
    hash = "sha256-CuuJ4B/f7JoGQuTo5LS3WqMD860tucZ6z/97atw94k0=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    morecantile
    rasterio
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Extend the functionality of morecantile with additional commands";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
