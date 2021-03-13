{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson-cloud";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1h7wwb5znjfyhzwbd0awwpqdwddby0zn2zy25cbfkqzbs44bs2sb";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
