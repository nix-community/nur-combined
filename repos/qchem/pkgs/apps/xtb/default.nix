{ stdenv, lib, gfortran, fetchFromGitHub, cmake, makeWrapper, blas, lapack
, turbomole ? null, orca ? null, cefine ? null
} :

stdenv.mkDerivation rec {
  pname = "xtb";
  version = "6.4.0";

  src = fetchFromGitHub  {
    owner = "grimme-lab";
    repo = pname;
    rev = "v${version}";
    sha256= "0fcf9f6y93aii907as25vmchfvdyzyrk0w7nqwyv1mjvab9a9acc";
  };

  nativeBuildInputs = [
    gfortran
    cmake
    makeWrapper
  ];

  buildInputs = [ blas lapack ];

  hardeningDisable = [ "format" ];

  postFixup = let
    # programs that XTB might call.
    binSearchPath = with lib; strings.makeSearchPath "bin" ([ ]
      ++ lists.optional (turbomole != null) turbomole
      ++ lists.optional (orca != null) orca
      ++ lists.optional (turbomole != null) cefine
    );
  in  ''
    wrapProgram $out/bin/xtb \
      --prefix PATH : "${binSearchPath}" \
      --set-default XTBPATH "$out/share/xtb"
  '';

  meta = with lib; {
    description = "Semiempirical Extended Tight-Binding Program Package";
    homepage = "https://www.chemie.uni-bonn.de/pctc/mulliken-center/grimme/software/xtb";
    license = licenses.lgpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
