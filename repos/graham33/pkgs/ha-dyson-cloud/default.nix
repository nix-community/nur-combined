{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson-cloud";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "04n3hsv333qysi816d2lwi0famhyw2xcj2x23kxl80jcm6i08q5q";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
