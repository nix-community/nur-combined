{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pkg-metadata";
  version = "0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pfmoore";
    repo = "pkg_metadata";
    rev = version;
    hash = "sha256-F19Xjy1VJnoonyZThXMplsUvuoqKnxl0k5+fm0tQp/k=";
  };

  nativeBuildInputs = [
    python3.pkgs.flit-core
  ];

  pythonImportsCheck = [ "pkg_metadata" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/pfmoore/pkg_metadata";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "pkg-metadata";
  };
}
