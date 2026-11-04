{
  lib,
  fetchFromGitHub,
  python3Packages,
  whitebox-tools,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "whitebox";
  version = "2.3.6";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "opengeos";
    repo = "whitebox-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xft1wbwrPOFd52QEtDyXvMZnYJDm8bSAODLQ9FEOFxQ=";
  };

  postPatch = ''
    substituteInPlace whitebox/whitebox_tools.py whitebox/download_wbt.py \
      --replace-fail 'if os.environ.get("WBT_PATH", None) is not None:' 'if True:'
    substituteInPlace whitebox/whitebox_tools.py \
      --replace-fail 'self.exe_path = path.dirname(path.abspath(__file__))' \
                     'self.exe_path = "${lib.getBin whitebox-tools}/bin"'
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ click ];

  pythonImportsCheck = [ "whitebox" ];

  meta = {
    description = "WhiteboxTools Python Frontend";
    homepage = "https://github.com/opengeos/whitebox-python";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
