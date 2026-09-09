{
  lib,
  python3Packages,
  rustPlatform,
  fetchPypi,
  fetchFromGitHub,

  nix-update-script,
  runCommand,
  testers,
}:
let
  # tombi-schema-store include_str!()s JSON schemas that live at the root of the
  # tombi repository, outside the crate directory that cargo vendors.
  tombiSchemas = fetchFromGitHub {
    owner = "tombi-toml";
    repo = "tombi";
    rev = "447bbe853ac15d1149976e9bbf85dd11fb55359e";
    sparseCheckout = [
      "www.schemastore.org"
      "www.schemastore.tombi"
    ];
    hash = "sha256-pzo9HxKai1eONT9sKZxIC5dPeB66ESiNbJ7tVfBOFHI=";
  };
in
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyproject-fmt";
  version = "2.29.4";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchPypi {
    pname = "pyproject_fmt";
    inherit (finalAttrs) version;
    hash = "sha256-/B/dD1qxsHrGpPTg8wREotfI8pZdLldGQdC+vHhPAbA=";
  };

  postPatch = ''
    cp -r ${tombiSchemas}/www.schemastore.org ${tombiSchemas}/www.schemastore.tombi "$cargoDepsCopy/"

    substituteInPlace src/pyproject_fmt/__main__.py src/pyproject_fmt/_lib.pyi \
      --replace-fail "from toml_fmt_common import" "from pyproject_fmt._vendor.toml_fmt_common import"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-IB0cJr1ODsL4qadGluqrNzf3tyEOxXrbj0Uub4tQtFQ=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  postInstall = ''
    vendor="$out/${python3Packages.python.sitePackages}/pyproject_fmt/_vendor"
    mkdir -p "$vendor"
    touch "$vendor/__init__.py"
    cp -r toml-fmt-common/src/toml_fmt_common "$vendor/"
  '';

  pythonImportsCheck = [ "pyproject_fmt" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    format =
      runCommand "test-pyproject-fmt-format"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          printf '[project]\nname="demo"\nversion="1.0.0"\n' >unformatted.toml
          pyproject-fmt --stdout unformatted.toml >formatted.toml || [ $? -eq 1 ]
          grep -Fqx 'name = "demo"' formatted.toml
          pyproject-fmt --check formatted.toml
          touch $out
        '';
  };

  meta = {
    description = "Format your pyproject.toml file";
    homepage = "https://github.com/tox-dev/toml-fmt";
    license = lib.licenses.mit;
    mainProgram = "pyproject-fmt";
    platforms = lib.platforms.all;
  };
})
