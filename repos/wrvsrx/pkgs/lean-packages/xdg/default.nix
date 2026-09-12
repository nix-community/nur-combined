{
  buildLakePackage,
  fetchFromGitHub,
}:
buildLakePackage rec {
  pname = "lean4-xdg";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "xdg";
    rev = version;
    hash = "sha256-+gTXSkGEW8a/2kv61zefKjdcIzcfRKmcb8KN8PcP/Tw=";
  };
  leanPackageName = "xdg";

  doCheck = true;
  checkPhase = ''
    lake test
  '';
}
