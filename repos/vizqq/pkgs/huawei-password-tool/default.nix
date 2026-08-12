{
  lib,
  stdenv,
  source,
  cmake,
  openssl,
}:

stdenv.mkDerivation {
  inherit (source) src;

  version = lib.replaceStrings [ "v" ] [ "" ] source.version;

  pname = "huawei-password-tool";

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
