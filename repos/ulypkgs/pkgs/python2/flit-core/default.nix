{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytoml,
}:

buildPythonPackage rec {
  pname = "flit-core";
  version = "2.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "flit";
    tag = version;
    hash = "sha256-4n6Na6KtH4QyJbVUi0U+dzA9zGsILPnDIsZH+9VpKxo=";
  };

  sourceRoot = "${src.name}/flit_core";

  propagatedBuildInputs = [ pytoml ];

  meta = {
    description = "Distribution-building parts of Flit. See flit package for more information";
    homepage = "https://github.com/pypa/flit";
    changelog = "https://github.com/pypa/flit/blob/${src.tag}/doc/history.rst";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.python ];
  };
}
