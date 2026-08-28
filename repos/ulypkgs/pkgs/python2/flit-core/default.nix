{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytoml,
}:

buildPythonPackage (finalAttrs: {
  pname = "flit-core";
  version = "2.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "flit";
    tag = finalAttrs.version;
    hash = "sha256-4n6Na6KtH4QyJbVUi0U+dzA9zGsILPnDIsZH+9VpKxo=";
  };

  sourceRoot = "${finalAttrs.src.name}/flit_core";

  propagatedBuildInputs = [ pytoml ];

  meta = {
    description = "Distribution-building parts of Flit. See flit package for more information";
    homepage = "https://github.com/pypa/flit";
    changelog = "https://github.com/pypa/flit/blob/${finalAttrs.src.tag}/doc/history.rst";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.python ];
  };
})
