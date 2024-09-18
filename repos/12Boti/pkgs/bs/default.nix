{ runCommandLocal, fetchFromGitHub }:
runCommandLocal "bs"
  {
    bsSrc = fetchFromGitHub {
      owner = "labaneilers";
      repo = "bs";
      rev = "3f49e6fcad52d3eab00fda326f256c1bebc3f8c4";
      hash = "sha256-py+gpuLxF2jKMSqUmsGqTUy5D9tEM368QAjr8HhN/xI=";
    };
  }
  ''
    install -Dm555 $bsSrc/bs $out/bin/bs
  ''
