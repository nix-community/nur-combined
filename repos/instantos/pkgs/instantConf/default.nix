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
    rev = "4b48e308b2bdb995e016999aa5e6bc74190067eb";
    sha256 = "0ys7dxp7cnr8lgfyar012rr53p8qmrv7a4l2jpk61bih5i9gxlha";
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
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
