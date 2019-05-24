{ stdenv, mylibs, sbcl, cacert, sqlite, freetds, libzip, curl, git, openssl, makeWrapper }:
stdenv.mkDerivation (mylibs.fetchedGithub ./pgloader.json // {
  # was removed from quicklisp packages cd7bfa6f48295f361c691a7520fb122938bd2a68,
  # but needs curl to build everything otherwise
  __noChroot = true;
  buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl makeWrapper ];
  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];
  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR
    make pgloader
  '';
  dontStrip = true;
  enableParallelBuilding = false;
  installPhase = ''
    install -Dm755 build/bin/pgloader "$out/bin/pgloader"
    wrapProgram $out/bin/pgloader --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH"
  '';
})
