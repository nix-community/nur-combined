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
  version = "5.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "canokeys";
    repo = "yubikey-manager";
    rev = "0836d0a97a6f18ce2a9dbe822d641eb7bfc3dadd";
    hash = "sha256-BBPRxx5VLqXIVQ9g0xJSpVmDaHRRHzs1zXgtClllMFc=";
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
