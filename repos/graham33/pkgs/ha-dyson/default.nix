{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1dckyx2hs5dv8k0wspan9qjd4m3p43px130yddyx166ff03gcqqb";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
