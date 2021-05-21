{ stdenv, lib, fetchurl, makeWrapper, cmake
, gfortran, mkl, fetchFromGitHub, xtb
} :

stdenv.mkDerivation rec {
  pname = "crest";
  version = "2021-04-24";

  nativeBuildInputs = [
    cmake
    makeWrapper
    gfortran
  ];

  buildInputs = [ mkl ];

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = pname;
    rev = "6a0f5c06c89d54567aab307a5d803e9ab6ba6a28";
    sha256 = "0kkx035zj4950jaf70vhd29yqd7qxapfrpic91rzbfx3la6n53fs";
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
  };
}
