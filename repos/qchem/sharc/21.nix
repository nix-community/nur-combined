{ stdenv, lib, fetchFromGitHub, makeWrapper, which, gfortran
, blas, liblapack, fftw, python2, molcas, bagel
, molpro, orca
, useMolpro ? false
, useOrca ? false
} :

let
  version = "2.1.1";
  python = python2.withPackages(p: with p; [ numpy pyquante ]);

in stdenv.mkDerivation {
  pname = "sharc";
  inherit version;

  src = fetchFromGitHub {
    owner = "sharc-md";
    repo = "sharc";
    rev = "Release2.1.1";
    sha256 = "1p9byiwlyqhbwdq0icxg75n3waxji0fiwp92q8jgrzb384k3bj36";
  };

  nativeBuildInputs = [ makeWrapper which ];
  buildInputs = [ gfortran blas liblapack fftw python ];

  patches = [
    # tests fail to create directories
    ./testing.patch
    # Molpro tests require more memory
    ./molpro_tests.patch
  ];

  postPatch = ''
    # SHARC make file (dynamics fixes)
    sed -i 's:^EXEDIR.*=.*:EXEDIR = ''${out}/bin:' source/Makefile;

    # purify output
    substituteInPlace source/Makefile --replace 'shell date' "shell echo $SOURCE_DATE_EPOCH" \
                                      --replace 'shell hostname' 'shell echo nixos' \
                                      --replace 'shell pwd' 'shell echo nixos'

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
                     --set LD_LIBRARY_PATH "$LD_LIBRARY_PATH" \
                     --set HOSTNAME localhost \
                     --set-default MOLCAS ${molcas} \
                     --set-default BAGEL ${bagel} \
                     ${lib.optionalString useMolpro "--set-default MOLPRO ${molpro}/bin"} \
                     ${lib.optionalString useOrca "--set-default ORCA ${orca}/bin"}
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
    note = "Untested";
  };
}

