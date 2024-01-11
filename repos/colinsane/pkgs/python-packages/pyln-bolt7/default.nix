# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-bolt7/default.nix>
{ buildPythonPackage, poetry-core, pytestCheckHook, clightning, pyln-proto }:

buildPythonPackage {
  pname = "pyln-bolt7";
  # the version is defined here:
  # - <https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-spec/bolt7/pyproject.toml>
  # update like:
  # - `nix build '.#clightning.src'`
  # - `dtrx ./result`
  # - `rg version <extracted>/clightning-v23.11.2/contrib/pyln-spec/bolt7/pyproject.toml`
  version = "1.0.4.246";
  format = "pyproject";

  inherit (clightning) src;

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ pyln-proto ];
  checkInputs = [ pytestCheckHook ];

  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-spec/bolt7";
}
