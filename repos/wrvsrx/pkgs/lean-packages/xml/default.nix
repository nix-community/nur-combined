{
  buildLakePackage,
  fetchFromGitHub,
}:
buildLakePackage rec {
  pname = "lean4-xml";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "xml";
    rev = version;
    hash = "sha256-bEJ7WTvH4+8N7LyhZW7LM/0HXtFpeoubKpNt1bkBXZE=";
  };
  leanPackageName = "xml";

  doCheck = true;
  checkPhase = ''
    lake test
  '';
}
