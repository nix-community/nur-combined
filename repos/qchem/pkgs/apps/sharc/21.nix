{ stdenv, lib, fetchFromGitHub, makeWrapper, which, gfortran
, blas, liblapack, fftw, python2, molcas, bagel, gnuplot, wfoverlap
# May all be null
, orca ? null, gaussian ? null, turbomole ? null, molpro ? null
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
    rev = "v${version}";
    sha256 = "09a5a0zbkganvx9g70vcjbr0i77a9kh095vgh0k0rm0lmkay1cd2";
  };

  nativeBuildInputs = [ makeWrapper which ];
  buildInputs = [ gfortran blas liblapack fftw python ];

  patches = [
    # tests fail to create directories
    ./testing.patch
    # Molpro tests require more memory
    ./molpro_tests.patch
    # Allows for newer molcas versions
    ./molcas_version.patch
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

  binSearchPath = with lib; strings.makeSearchPath "bin" ([ molcas bagel gnuplot ]
    ++ lists.optional (orca != null) orca
    ++ lists.optional (gaussian != null) gaussian
    ++ lists.optional (turbomole != null) turbomole
    ++ lists.optional (molpro != null) molpro
  );

  installPhase = ''
    mkdir -p $out/bin $out/share/sharc/tests

    cd source
    make install
    cd ..

    cp -u bin/* $out/bin
    cp wfoverlap/scripts/* $out/bin
    cp ${wfoverlap}/bin/wfoverlap.x $out/bin/wfoverlap_ascii.x

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
                     ${lib.optionalString (molpro != null) "--set-default MOLPRO ${molpro}/bin"} \
                     ${lib.optionalString (orca != null) "--set-default ORCADIR ${orca}/bin"} \
                     ${lib.optionalString (turbomole != null) "--set-default TURBOMOLE ${turbomole}/bin"} \
                     ${lib.optionalString (gaussian != null) "--set-default GAUSSIAN ${gaussian}/bin"}
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

  setupHooks = [
    ./sharcHook.sh
  ];

  meta = with lib; {
    description = "Molecular dynamics (MD) program suite for excited states";
    homepage = https://www.sharc-md.org;
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
    note = "Untested";
  };
}
