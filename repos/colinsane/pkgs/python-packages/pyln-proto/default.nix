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

  # package pins its dependencies too aggressively
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'coincurve = "^18"' 'coincurve = ">=18"' \
      --replace-fail 'cryptography = "^41"' 'cryptography = ">=41"'
  '';

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
