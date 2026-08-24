{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  aiohttp,
  nix-update-script,
  poetry-core,
  setuptools,
  websockets,
}:
buildPythonPackage (finalAttrs: {
  pname = "smartrent_py";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zacherythomas";
    repo = "smartrent-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UptzFqGpQtefvBE2X0ji1UvEOP8+f/E0w64XuVoVpSM=";
  };
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"poetry>=' '"poetry-core>='
  '';

  propagatedBuildInputs = [
    aiohttp
    poetry-core
    setuptools
    websockets
  ];

  pythonImportsCheck = [ "smartrent" ];

  # Upstream dependency restriction is too strict
  dontCheckRuntimeDeps = true;

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/zacherythomas/smartrent-py/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Api for SmartRent locks, thermostats, moisture sensors and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent.py";
    license = with lib.licenses; [ mit ];
  };
})
