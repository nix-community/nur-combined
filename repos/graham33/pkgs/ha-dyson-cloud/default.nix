{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson-cloud";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1mazvisai7pwiqrjv47a38hb01vy3489g6vfi8d95iaszcx34nlc";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
