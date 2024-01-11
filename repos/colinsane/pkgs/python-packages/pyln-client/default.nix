# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-client/default.nix>
{ buildPythonPackage, poetry-core, pytestCheckHook, clightning, pyln-bolt7, pyln-proto }:

buildPythonPackage {
  pname = "pyln-client";
  format = "pyproject";

  inherit (clightning) src version;

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    pyln-bolt7
    pyln-proto
  ];

  checkInputs = [ pytestCheckHook ];

  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-client";
}
