{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.tree-sitter-tmux) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    tree-sitter
  ];
  nativeBuildInputs = [
    setuptools
  ];

  meta = with lib; {
    homepage = "https://tree-sitter-tmux.readthedocs.io";
    description = "tmux grammar for tree-sitter";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
