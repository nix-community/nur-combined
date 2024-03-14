{ mySources
, python3
, lib
, fetchFromGitHub
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.tree-sitter-languages) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    tree-sitter
  ];
  nativeBuildInputs = [
    setuptools
    cython
  ];
  pythonImportsCheck = [
    "tree_sitter_languages"
  ];
  preBuild = import ./fetchLanguages.nix fetchFromGitHub;

  meta = with lib; {
    homepage = "https://github.com/grantjenks/py-tree-sitter-languages";
    description = "binary Python wheels for all tree sitter languages";
    license = licenses.asl20;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
