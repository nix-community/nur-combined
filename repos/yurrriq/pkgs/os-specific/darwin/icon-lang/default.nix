{ stdenv, fetchurl }:

stdenv.mkDerivation rec {

  name = "icon-lang-${version}";
  version = "9.5.1";

  src = fetchurl {
    url = "http://www2.cs.arizona.edu/icon/ftp/binaries/unix/mac-x64n-v${stdenv.lib.strings.replaceChars ["."] [""] version}.tgz";
    sha256 = "144x3rl81zdgr1hrxff1a3pchcgazjvwzcnvfx9svg382bkc5zcs";
  };

  dontBuild = true;

  installPhase = ''
    ls
    for dir in bin lib; do
      mkdir -p $out/$dir
      cp -rv $dir $out/
    done
  '';

  meta = {
    platforms = stdenv.lib.platforms.darwin;
  };

}
