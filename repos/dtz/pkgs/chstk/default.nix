{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "chstk-${version}";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Gottox";
    repo = "chstk";
    rev = "v${version}";
    sha256 = "1zdp37y9wfain8qwnyrf6lvr6nvz84hbnffflc3b2b1m5bwxjh8l";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv chstk $out/bin/chstk
  '';

  meta = with stdenv.lib; {
    description = "change or display the stack size of an ELF binary";
    homepage = https://github.com/Gottox/chstk;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
