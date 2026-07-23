{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  installShellFiles,
  procps,
}:

python3Packages.buildPythonPackage rec {
  pname = "canokey-manager";
  version = "4.1.0a1-unstable";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "canokeys";
    repo = "yubikey-manager";
    rev = "8c04e105c94c723de3ea8ee7df3475a80c7b8eab";
    hash = "sha256-8Viyb8BynCkXnUpUKlp/gJMb/ImHQJ0rmDvcpoOU5zM=";
  };

  postPatch = ''
    substituteInPlace "ykman/pcsc/__init__.py" \
      --replace 'pkill' '${if stdenv.hostPlatform.isLinux then procps else "/usr"}/bin/pkill'
  '';

  nativeBuildInputs = with python3Packages; [
    poetry-core
    installShellFiles
  ];

  propagatedBuildInputs = with python3Packages; [
    cryptography
    pyscard
    fido2
    click
    keyring
  ];

  pythonRelaxDeps = [
    "keyring"
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    makefun
  ];
  disabledTestPaths = [ "tests/device" ];

  meta = {
    homepage = "https://developers.yubico.com/yubikey-manager";
    changelog = "https://github.com/Yubico/yubikey-manager/releases/tag/${version}";
    description = "Command line tool for configuring any YubiKey over all USB transports";

    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      benley
      lassulus
      pinpox
      nickcao
    ];
    mainProgram = "ckman";
  };
}
