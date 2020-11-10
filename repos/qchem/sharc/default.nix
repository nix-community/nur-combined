{ stdenv, lib, fetchFromGitHub, makeWrapper, gfortran
, openblasCompat, fftw, python2, molcas, molpro
, useMolpro ? false
} :

let
  version = "2.0";
  python = python2.withPackages(p: with p; [ numpy ]);

in stdenv.mkDerivation {
  pname = "sharc";
  inherit version;

  src = fetchFromGitHub {
    owner = "sharc-md";
    repo = "sharc";
    rev = "V${version}";
    sha256 = "14zsmqpcxjsycfqwdknfl9jqlpdyjxf4kagjh1kyrfq0lyavh6dm";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ gfortran openblasCompat fftw python ];

  patches = [
    # tests fail to create directories
    ./testing.patch
    # Molpro tests require more memory
    ./molpro_tests.patch
  ];

  postPatch = ''
    # SHARC make file
    sed -i 's/^F90.*=.*/F90 = gfortran/' source/Makefile;
    sed -i 's/^LD.*=.*/LD = -lopenblas -lfftw3/' source/Makefile;
    sed -i 's:^EXEDIR.*=.*:EXEDIR = ''${out}/bin:' source/Makefile;

    # purify output
    substituteInPlace source/Makefile --replace 'shell date' 'shell echo 0' \
                                      --replace 'shell hostname' 'shell echo nixos' \
                                      --replace 'shell pwd' 'shell echo nixos'


    # WF overlap
    sed -i 's:^LALIB.*=.*:LALIB = -lopenblas -fopenmp:' wfoverlap/source/Makefile;

    rm bin/*.x

    patchShebangs wfoverlap/scripts
  '';

  buildPhase = ''
    cd wfoverlap/source
    make wfoverlap_ascii.x
    cd ../../source
    make
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/sharc/tests

    cd source
    make install
    cd ..

    cp -u bin/* $out/bin
    cp wfoverlap/scripts/* $out/bin

    cp doc/* $out/share/sharc
    cp -r tests/* $out/share/sharc/tests

    chmod +x $out/bin/*

    ln -s $out/share/sharc/tests $out/tests

    for i in $(find $out/bin -type f); do
      wrapProgram $i --set SHARC $out/bin \
                     --set HOSTNAME localhost \
                     --set-default MOLCAS ${molcas} \
                     ${lib.optionalString useMolpro "--set-default MOLPRO ${molpro}/bin"}
    done
  '';

  postFixup = ''
    for i in $(find $out/share -name run.sh); do
       # shebang is broken (missing !)
       echo "fixing $i"
       sed -i '1s:.*:#!${stdenv.shell}:' $i
       sed -i "s:\$SHARC:$out/bin:" $i
       sed -i 's/cd \$COPY_DIR/cd $COPY_DIR\;chmod -R +w \*/' $i
    done
  '';

  meta = with lib; {
    description = "Molecular dynamics (MD) program suite for excited states";
    homepage = https://www.sharc-md.org;
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

