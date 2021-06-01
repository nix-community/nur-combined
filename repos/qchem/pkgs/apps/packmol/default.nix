{ stdenv, lib, gfortran, fetchFromGitHub } :

stdenv.mkDerivation rec {
  pname = "packmol";
  version = "20.2.3";

  buildInputs = [ gfortran ];

  src = fetchFromGitHub {
    owner = "m3g";
    repo = pname;
    rev = "v${version}";
    sha256= "0z9x8n2ippffkg5gi0b7vgw0dj3zhvm7p1n2ajybkh3n2xv84bhq";
  };

  dontConfigure = true;

  patches = [ ./MakeFortran.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp -p packmol $out/bin
  '';

  hardeningDisable = [ "format" ];

  meta = with lib; {
    description = "Generating initial configurations for molecular dynamics";
    homepage = "http://m3g.iqm.unicamp.br/packmol/home.shtml";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
