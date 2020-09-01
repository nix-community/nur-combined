{ lib, stdenv,  fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "hactool";
  name = "${pname}-${version}";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "SciresM";
    repo = "hactool";
    rev = version;
    sha256 = "0305ngsnwm8npzgyhyifasi4l802xnfz19r0kbzzniirmcn4082d";
  };
  preBuild = ''
    cp config.mk.template config.mk
  '';
  installPhase = ''
    install -D hactool $out/bin/hactool
  '';
  buildInputs = [ ];
  nativeBuildInputs = [ ];

  meta = {
    description = "tool to view information about, decrypt, and extract common file formats for the Nintendo Switch, especially Nintendo Content Archives";
    homepage = https://github.com/SciresM/hactool;
    license = stdenv.lib.licenses.isc;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
