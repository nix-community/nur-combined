{
  lib,
  fetchFromGitHub,
  python3,
  nix-update-script,
  versionCheckHook,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "anemoi";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dayt0n";
    repo = "anemoi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V8evm5eNxUhQVY9xvLkq2jLBpLXdTIvcPH/VbIU6+NU=";
  };

  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    click
    flask
    arrow
    tinydb
    requests
    cloudflare
    bcrypt
    peewee
    psycopg2
    jsonschema
    pyyaml
  ];

  pythonImportsCheck = [ "anemoi" ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Anemoi is a least privilege dynamic DNS server";
    homepage = "https://github.com/dayt0n/anemoi";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.freebsd;
    mainProgram = "anemoi";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
