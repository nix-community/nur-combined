{ stdenv, lib, gfortran, fetchFromGitHub, cmake, makeWrapper, blas, lapack, writeTextFile
, turbomole ? null, orca ? null, cefine ? null
} :

let
  description = "Semiempirical extended tight-binding program package";

  binSearchPath = with lib; strings.makeSearchPath "bin" ([ ]
    ++ lists.optional (turbomole != null) turbomole
    ++ lists.optional (orca != null) orca
    ++ lists.optional (turbomole != null) cefine
  );

in stdenv.mkDerivation rec {
  pname = "xtb";
  version = "6.4.1";

  src = fetchFromGitHub  {
    owner = "grimme-lab";
    repo = pname;
    rev = "v${version}";
    sha256= "1cakkysjj5qm3dhia0f3frp68rysc1p6p4hm8z36j20j02vmks0i";
  };

  nativeBuildInputs = [
    gfortran
    cmake
    makeWrapper
  ];

  buildInputs = [ blas lapack ];

  hardeningDisable = [ "format" ];

  postInstall = ''
    mkdir -p $out/lib/pkgconfig

    cat > $out/lib/pkgconfig/xtb.pc << EOF
    prefix=$out
    libdir=''${prefix}/lib
    includedir=''${prefix}/include

    Name: ${pname}
    Description: ${description}
    Version: ${version}
    Cflags: -I''${prefix}/include
    Libs: -L''${prefix}/lib -lxtb
    EOF
  '';

  postFixup = ''
    wrapProgram $out/bin/xtb \
      --prefix PATH : "${binSearchPath}"
  '';

  setupHooks = [ ./xtbHook.sh ];

  meta = with lib; {
    inherit description;
    homepage = "https://www.chemie.uni-bonn.de/pctc/mulliken-center/grimme/software/xtb";
    license = licenses.lgpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
