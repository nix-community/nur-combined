{ lib
, stdenv
, fetchFromGitHub
, sqlite
}:
stdenv.mkDerivation {

  pname = "instantConf";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantconf";
    rev = "aac6ab4e3b9263b464ed14234f957c47016ac371";
    sha256 = "waLwo9w+s2KoZp1rzDk43OACadkFif4iyabjghL/uDo=";
    name = "instantOS_instantConf";
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
    description = "instantOS Conf";
    license = licenses.gpl2;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
