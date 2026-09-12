{
  buildLakePackage,
  fetchFromGitHub,
}:
buildLakePackage rec {
  pname = "lean4-lean-posix";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "lean-posix";
    rev = version;
    hash = "sha256-CkoymdIR/6VLq6ATMx3786a0qP8Y42xRTsGJhxM6NH0=";
  };
  leanPackageName = "«lean-posix»";
}
