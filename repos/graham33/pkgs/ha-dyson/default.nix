{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ha-dyson";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1zd0q8cn7zwfhc8djsap1v4zbhzs2s1achapsv5ic0g84gns5zwx";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
