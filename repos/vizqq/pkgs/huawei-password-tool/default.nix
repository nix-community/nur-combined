{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "huawei-password-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "0xuserpag3";
    repo = "HuaweiPasswordTool";
    rev = "v${version}";
    hash = "sha256-uvLY+/XAE62Ft+bEm2t5SNhXb5nrWPQouJEdAkrguYg=";
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [
    cmake
  ];

  installPhase = ''
    mv hw_passwd huawei-password-tool
    cp huawei-password-tool $out
  '';

  meta = {
    description = "Tool for enc/dec huawei format password";
    homepage = "https://github.com/0xuserpag3/HuaweiPasswordTool";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "huawei-password-tool";
  };
}
