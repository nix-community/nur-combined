{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1fx1q57a5pr7rxmxszax6icp3ramflmqj80fhwyyjwhwjm4z7szl";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
