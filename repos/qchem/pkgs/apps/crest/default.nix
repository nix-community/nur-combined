{ stdenv, lib, fetchurl, makeWrapper, cmake
, gfortran, mkl, fetchFromGitHub, xtb
} :

stdenv.mkDerivation rec {
  pname = "crest";
  version = "2.11.1";

  nativeBuildInputs = [
    cmake
    makeWrapper
    gfortran
  ];

  buildInputs = [ mkl ];

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = pname;
    rev = "v${version}";
    sha256 = "/6f5MH+0AHXrVC26KA3fXTrJYuNSfeW3H79dJPMjuRw=";
  };

  FFLAGS = "-ffree-line-length-512";

  hardeningDisable = [ "all" ];

  postFixup = ''
    wrapProgram $out/bin/crest \
      --prefix PATH : "${xtb}/bin"
  '';

  meta = with lib; {
    description = "Conformer-Rotamer Ensemble Sampling Tool based on the xtb Semiempirical Extended Tight-Binding Program Package";
    license = licenses.gpl3Only;
    homepage = "https://github.com/grimme-lab/crest";
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
