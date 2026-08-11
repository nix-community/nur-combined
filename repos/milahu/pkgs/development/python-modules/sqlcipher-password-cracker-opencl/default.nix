{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  pysqlcipher3,
  pyopencl,
}:

buildPythonApplication rec {
  pname = "sqlcipher-password-cracker-opencl";
  version = "unstable-2025-10-27";

  src = fetchFromGitHub {
    owner = "whiteblackitty";
    repo = "SQLCipher-Password-Cracker-OpenCL";
    rev = "1e8753a88fc88aa9593ee6026a08ede37cd49232";
    hash = "sha256-il8EFZfY/9QMIi0gkl5lTeFflU7eANWG6dj82tg+/8o=";
  };

  propagatedBuildInputs = [
    pysqlcipher3
    pyopencl
  ];

  meta = {
    description = "Password cracker for SQLCipher v2 using OpenCL";
    homepage = "https://github.com/whiteblackitty/SQLCipher-Password-Cracker-OpenCL";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sqlcipher-password-cracker-opencl";
    platforms = lib.platforms.all;
  };
}
