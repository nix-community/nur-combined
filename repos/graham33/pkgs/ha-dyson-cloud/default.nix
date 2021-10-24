{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson-cloud";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1vzv6gpip5b0ljdiwq7d863xd72hkwh5376brqbaabhhiy6m4n5v";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
