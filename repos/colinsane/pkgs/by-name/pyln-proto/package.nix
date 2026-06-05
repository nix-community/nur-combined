# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-proto/default.nix>
{
  clightning,
  python3,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "pyln-proto";

  inherit (clightning) src version;

  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-proto";

  nativeBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    unzip  # used by `unpackPhase`
  ];

  propagatedBuildInputs = [
    python3.pkgs.bitstring
    python3.pkgs.cryptography
    python3.pkgs.coincurve
    python3.pkgs.base58
    python3.pkgs.pysocks
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  doCheck = true;
  strictDeps = true;
}
