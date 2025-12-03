# based on: <https://github.com/fort-nix/nix-bitcoin/blob/master/pkgs/python-packages/pyln-bolt7/default.nix>
{
  clightning,
  pyln-proto,
  python3,
  stdenv,
  unzip,
}:
stdenv.mkDerivation {
  pname = "pyln-bolt7";
  # the version is defined here:
  # - <https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-spec/bolt7/pyproject.toml>
  # update like:
  # - `nix build '.#clightning.src'`
  # - `dtrx ./result`
  # - `rg version <extracted>/clightning-v23.11.2/contrib/pyln-spec/bolt7/pyproject.toml`
  version = "1.0.4.246";

  inherit (clightning) src;
  sourceRoot = "clightning-v${clightning.version}/contrib/pyln-spec/bolt7";

  nativeBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    unzip  # used by `unpackPhase`
  ];
  propagatedBuildInputs = [
    pyln-proto
  ];
  nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];

  doCheck = true;
  strictDeps = true;
}
