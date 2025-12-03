{
  lib,
  stdenv,
  appdirs,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  mock,
  psutil,
  pyftpdlib,
  pytestCheckHook,
  pythonOlder,
  pytz,
  parameterized,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "fs";
  version = "2.4.17";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src =
  if true then
  fetchFromGitHub {
    # https://github.com/PyFilesystem/pyfilesystem2/pull/590
    # https://github.com/milahu/pyfilesystem2/tree/pkg-resources-part-1-and-2
    owner = "milahu";
    repo = "pyfilesystem2";
    rev = "70dc40dae57bbdb579f42cff30cb993a674018a0";
    hash = "sha256-XSDR9AMTWEcnyQ440GRYylMIz0tw0dR3l3LB3wo9kqI=";
  }
  else
  fetchPypi {
    inherit pname version;
    hash = "sha256-rpfH1RIT9LcLapWCklMCiQkN46fhWEHhCPvhRPBp0xM=";
  };

  postPatch = ''
    # https://github.com/PyFilesystem/pyfilesystem2/pull/591
    substituteInPlace tests/test_ftpfs.py \
      --replace ThreadedTestFTPd FtpdThreadWrapper
  '';

  build-system = [ setuptools ];

  dependencies = [
    setuptools
    six
    appdirs
    pytz
    parameterized
  ];

  nativeCheckInputs = [
    pyftpdlib
    mock
    psutil
    pytestCheckHook
  ];

  LC_ALL = "en_US.utf-8";

  preCheck = ''
    HOME=$(mktemp -d)
  '';

  disabledTestPaths = [
    # Circular dependency with parameterized
    "tests/test_move.py"
    "tests/test_mirror.py"
    "tests/test_copy.py"
  ];

  disabledTests =
    [
      "user_data_repr"
      # https://github.com/PyFilesystem/pyfilesystem2/issues/568
      "test_remove"
      # Tests require network access
      "TestFTPFS"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
      # remove if https://github.com/PyFilesystem/pyfilesystem2/issues/430#issue-707878112 resolved
      "test_ftpfs"
    ];

  pythonImportsCheck = [ "fs" ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Filesystem abstraction";
    homepage = "https://github.com/PyFilesystem/pyfilesystem2";
    changelog = "https://github.com/PyFilesystem/pyfilesystem2/blob/v${version}/CHANGELOG.md";
    license = licenses.bsd3;
    maintainers = with maintainers; [ lovek323 ];
    platforms = platforms.unix;
  };
}
