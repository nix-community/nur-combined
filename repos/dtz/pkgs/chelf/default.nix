{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "chelf-${version}";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Gottox";
    repo = "chelf";
    rev = "v${version}";
    sha256 = "0rnw34f4xzwpd07axim4f88f9v6abfpm2bkrgd64lwvwkhhnajqc";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv chelf $out/bin/chelf
  '';

  meta = with stdenv.lib; {
    description = "change or display the stack size of an ELF binary";
    homepage = https://github.com/Gottox/chelf;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
