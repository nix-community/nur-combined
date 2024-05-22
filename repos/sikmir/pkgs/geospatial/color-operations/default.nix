{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "color-operations";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vincentsarago";
    repo = "color-operations";
    rev = version;
    hash = "sha256-xGugXOpCqI8+06faCf3AjjpJaOkblkGoyaDG3AyrZoI=";
  };

  nativeBuildInputs = with python3Packages; [ numpy ];

  pythonImportsCheck = [ "color_operations" ];

  meta = with lib; {
    description = "Apply basic color-oriented image operations. Fork of rio-color";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
