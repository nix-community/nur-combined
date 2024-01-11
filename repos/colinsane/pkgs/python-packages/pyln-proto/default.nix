# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-proto/default.nix>
{ buildPythonPackage
, clightning
, poetry-core
, pytestCheckHook
, bitstring
, cryptography
, coincurve
, base58
, pysocks
}:

buildPythonPackage {
  pname = "pyln-proto";
  format = "pyproject";

  inherit (clightning) src version;

  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-proto";

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    bitstring
    cryptography
    coincurve
    base58
    pysocks
  ];

  checkInputs = [ pytestCheckHook ];
}
