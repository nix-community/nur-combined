{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "pfetch";
  version = "unstable-2019-10-03";
  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = pname;
    rev = "8b9c409650f290585571f733726f3bd2c1138ac6";
    sha256 = "180vvbmvak888vs4dgzlmqk0ss4qfsz09700n4p8s68j7krkxsfq";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm755 -t $out/bin pfetch
  '';
}
