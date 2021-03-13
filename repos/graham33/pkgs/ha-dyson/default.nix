{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1b3hbv78bx7bvy52j65121niwx2x4pnwa1086xzyswgsmnm3y8i0";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
