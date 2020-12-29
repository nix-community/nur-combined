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
    rev = "fa62b19e3e7cae55e3623895a0a02a040f8652fc";
    sha256 = "sha256-8FNjTUHX80L9FfB4RY5xOSKsXn6xfo83JIsNLcBE1GU=";
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
