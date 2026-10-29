{
  lib,
  fetchFromGitLab,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "buildgrid";
  version = "0.9.4";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitLab {
    owner = "BuildGrid";
    repo = "buildgrid";
    tag = finalAttrs.version;
    hash = "sha256-Law/N6psYGamdoickoxQGIZV1e0l7FMOvp0xuo7vtCk=";
  };

  pythonRelaxDeps = [
    "pycurl" # 7.45.6 vs 7.46.0
    "sqlalchemy" # 2.0.51 vs 2.1
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
    psycopg
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
