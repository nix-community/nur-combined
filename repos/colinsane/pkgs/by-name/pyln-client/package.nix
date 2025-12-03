# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-client/default.nix>
{
  clightning,
  pyln-bolt7,
  pyln-proto,
  python3,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "pyln-client";
  format = "pyproject";

  inherit (clightning) src version;
  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-client";

  nativeBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    unzip  # used by `unpackPhase`
  ];

  propagatedBuildInputs = [
    pyln-bolt7
    pyln-proto
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  doCheck = true;
  strictDeps = true;
}
