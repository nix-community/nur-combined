{
  lib,
  python3Packages,
  rustPlatform,
  fetchPypi,
  fetchFromGitHub,
  nur,

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
  version = "2.28.0";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchPypi {
    pname = "pyproject_fmt";
    inherit (finalAttrs) version;
    hash = "sha256-4iQ33n4/St1g5l/pNaZd9rxRPt2CcEHzlwE9eBmc4UY=";
  };

  postPatch = ''
    cp -r ${tombiSchemas}/www.schemastore.org ${tombiSchemas}/www.schemastore.tombi "$cargoDepsCopy/"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-vRz0tQKw0BhM2hAX6mS9WLtusXEYMQtTE4WTVVEg0xA=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  dependencies = [
    nur.repos.josh.python3-toml-fmt-common
  ];

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
