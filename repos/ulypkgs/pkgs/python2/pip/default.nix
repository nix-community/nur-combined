{
  lib,
  buildPythonPackage,
  bootstrapped-pip,
  fetchFromGitHub,
  mock,
  scripttest,
  virtualenv,
  pretend,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "pip";
  version = "20.3.4";
  format = "other";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-lketnZ53yVL1wzCjiXABrBivR2N+8mRfkE2ywHzScEI=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-source";
  };

  nativeBuildInputs = [ bootstrapped-pip ];

  # pip detects that we already have bootstrapped_pip "installed", so we need
  # to force it a little.
  pipInstallFlags = [ "--ignore-installed" ];

  checkInputs = [
    mock
    scripttest
    virtualenv
    pretend
    pytest
  ];
  # Pip wants pytest, but tests are not distributed
  doCheck = false;

  meta = {
    description = "The PyPA recommended tool for installing Python packages";
    license = with lib.licenses; [ mit ];
    homepage = "https://pip.pypa.io/";
    priority = 10;
  };
})
