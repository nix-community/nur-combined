{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "0b7372m0ilrs1l01qpxh0pd1d9kyxg4kx12g9wifbpv8r74m9x69";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
