{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "0igk6k39qb281kk4m5nyrp255lzjspb0g27dk87zf4s3q180xykx";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
