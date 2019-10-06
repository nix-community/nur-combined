{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "pfetch";
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = pname;
    rev = "refs/tags/${version}";
    sha256 = "180vvbmvak888vs4dgzlmqk0ss4qfsz09700n4p8s68j7krkxsfq";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm755 -t $out/bin pfetch
  '';
}
