{
  stdenv,
  gcc,
  makeWrapper,
}:
stdenv.mkDerivation {
  name = "fire6";
  version = "6.5.2";
  src = fetchGit {
    url = "https://gitlab.com/feynmanintegrals/fire.git";
    rev = "51bd31ac3496bc0e88399ee32e4429a500fa796d";
    submodules = true;
  };
  buildInputs = [ gcc ];
  buildPhase = ''
    cd FIRE6
    export CCPLUS=$CXX
    ./configure
    make dep
    make
    cd ..
  '';
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp FIRE6/bin/FIRE6 $out/bin/
    # TODO: This is not very multi platform 
    # Maybe just copy everything from lib?
    cp FIRE6/usr/lib/*.dylib $out/lib/
  '';
  nativeBuildInputs = [ makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/FIRE6 \
    --prefix LD_LIBRARY_PATH : $out/lib \
    --prefix DYLD_LIBRARY_PATH : $out/lib
  '';
  patches = [ ./fire6.patch ];
}
