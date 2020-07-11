{ lib
, stdenv
, fetchFromGitHub
, instantMENU
}:
stdenv.mkDerivation {

  pname = "imenu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "imenu";
    rev = "18e35de1f6137180876be800d5ae749e40c5f7e9";
    sha256 = "0mzwpyrr3q8yp5wccsggiybfxsw80q8j5plf964isakapbn86dhj";
  };

  propagatedBuildInputs = [
    instantMENU
  ];

  installPhase = ''
    install -Dm 555 imenu.sh $out/bin/imenu
  '';

  meta = with lib; {
    description = "instantOS imenu";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/imenu";
    maintainers = [ "con-f-use <con-f-use@gmx.net" ];
    platforms = platforms.linux;
  };
}
