{
  lib,
  python3,
  fetchFromGitHub,
  cargo,
  pkg-config,
  rustPlatform,
  rustc,
  bzip2,
  openssl,
}:

# python3.pkgs.buildPythonApplication (finalAttrs: {
python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "securedrop";
  version = "2.16.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "freedomofpress";
    repo = "securedrop";
    tag = finalAttrs.version;
    hash = "sha256-LTfzTz+IlUGzHgDaiazIFbhxzfiU9yqLurmAdVevFK8=";
  };

  postPatch = ''
    # fix: configuration error: `project` must contain ['version'] properties
    substituteInPlace pyproject.toml \
      --replace-fail \
        '[project]' \
        "$(
          echo '[project]'
          echo 'version = "${finalAttrs.version}"'
        )"

    # fix: error: Multiple top-level packages discovered in a flat-layout
    cat >>pyproject.toml <<'EOF'
    [tool.setuptools]
    packages = ["securedrop"]
    EOF
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-hgZAMqyJ1TIQN+jkEc4HOsotx6H/ky/fy+iBxWB3jXE=";
  };

  build-system = [
    cargo
    pkg-config
    python3.pkgs.setuptools
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [
    bzip2
    openssl
  ];

  pythonImportsCheck = [
    "securedrop"
  ];

  meta = {
    description = "whistleblower platform";
    homepage = "https://github.com/freedomofpress/securedrop";
    changelog = "https://github.com/freedomofpress/securedrop/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "securedrop";
  };
})
