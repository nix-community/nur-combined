{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson-cloud";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1p5c13i6qvmcfisid3rvhq49dbkja5a5mw7yk1sja53i79w06xzq";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
