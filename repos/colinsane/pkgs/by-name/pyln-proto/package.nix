# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-proto/default.nix>
{
  clightning,
  python3,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "pyln-proto";
  format = "pyproject";

  inherit (clightning) src version;

  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-proto";

  nativeBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    unzip  # used by `unpackPhase`
  ];

  propagatedBuildInputs = with python3.pkgs; [
    bitstring
    cryptography
    coincurve
    base58
    pysocks
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  doCheck = true;
  strictDeps = true;
}
