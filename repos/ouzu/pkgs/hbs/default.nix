{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "hbs";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "LovesToCode";
    repo = "hbs-How-Big-Search";
    rev = "v${version}";
    sha256 = "1yjggasb4snvfpyrx8zh6idchy29kskq35nvavc0k2wvgm16jv3h";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp hbs $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A command line utility that searches for files, and tells you how big it all is.";
    homepage = "https://github.com/LovesToCode/hbs-How-Big-Search";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}