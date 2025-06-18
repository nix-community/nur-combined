{ fetchFromGitHub }:
rec {
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-ExUHMmMt0QcP/G+xMUrMQiCJnxsc8t2m/Xm4bPZLclA=";
  };
}
