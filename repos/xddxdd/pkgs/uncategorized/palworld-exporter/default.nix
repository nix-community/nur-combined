{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3Packages,
  click-loglevel,
  rcon,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "palworld-exporter";
  version = "1.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "palworldlol";
    repo = "palworld-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1hYOiU3fYQBOKEqE6HvqmLF4+kS+PjAph0LoYpmglrg=";
  };
  # Remove dependency on get_version package
  postPatch = ''
    sed -i "/get_version/d" pyproject.toml
    echo "__version__ = '${finalAttrs.version}'.removeprefix('v')" > src/palworld_exporter/__init__.py
    sed -i "s/prometheus-client>=0.19,<0.20/prometheus-client/g" pyproject.toml
  '';

  propagatedBuildInputs = with python3Packages; [
    setuptools
    click
    click-loglevel
    prometheus-client
    rcon
    requests
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };
  meta = {
    mainProgram = "palworld_exporter";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Prometheus exporter for Palworld Server";
    homepage = "https://github.com/palworldlol/palworld-exporter";
    license = with lib.licenses; [ mit ];
  };
})
