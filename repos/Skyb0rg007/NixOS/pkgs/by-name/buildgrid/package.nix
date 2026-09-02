{
  lib,
  fetchFromGitLab,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "buildgrid";
  version = "0.8.10";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "BuildGrid";
    repo = "buildgrid";
    tag = finalAttrs.version;
    hash = "sha256-M+TmsYe5QEtPpwzXgruD84Gd37KQd4SmbYAoRW0dh9o=";
  };

  pythonRelaxDeps = [
    "pycurl" # 7.45.6 vs 7.46.0
  ];
  pythonRemoveDeps = [
    "lark-parser" # Nixpkgs calls this package 'lark'
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];
  dependencies = with python3.pkgs; [
    alembic
    boto3
    botocore
    buildgrid-metering-client
    click
    cryptography
    dnspython
    grpcio
    grpcio-health-checking
    grpcio-reflection
    janus
    jinja2
    jsonschema
    lark
    mmh3
    protobuf
    pycurl
    pydantic
    pyjwt
    pyyaml
    requests
    sentry-sdk
    sqlalchemy
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python remote execution service";
    homepage = "https://buildgrid.build";
    mainProgram = "bgd";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
