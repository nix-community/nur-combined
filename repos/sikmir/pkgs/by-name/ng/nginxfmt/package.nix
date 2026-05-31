{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nginxfmt";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "slomkowski";
    repo = "nginx-config-formatter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HB1knL/q1G2z6RyVCsOyIKpp4O6x68/93ccvox1FKGQ=";
  };

  build-system = with python3Packages; [ poetry-core ];

  meta = {
    description = "nginx config file formatter/beautifier";
    homepage = "https://github.com/slomkowski/nginx-config-formatter";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "nginxfmt";
  };
})
