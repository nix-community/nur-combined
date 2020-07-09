{ lib
, stdenv
, fetchFromGitHub
, sqlite
}:
stdenv.mkDerivation rec {

  pname = "InstantConf";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantconf";
    rev = "master";
    sha256 = "0s4xs2g7946bwl10h3n3w8ll0am9b602ad8f64jq3azi5w72wfq8";
  };

  postPatch = ''
    substituteInPlace instantconf \
      --replace sqlite3 "${lib.getBin sqlite}/bin/sqlite3"
  '';

  installPhase = ''
    install -Dm 555 instantconf $out/bin/instantconf
    ln -s $out/bin/instantconf $out/bin/iconf
  '';

  propagatedBuildInputs = [ sqlite ];

  meta = with lib; {
    description = "InstantOS Conf";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
