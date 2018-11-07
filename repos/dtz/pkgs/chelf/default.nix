{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "chelf-${version}";
  version = "2018-10-29";

  src = fetchFromGitHub {
    owner = "Gottox";
    repo = "chelf";
    rev = "c3204f80e9db350f2ba6498b684356f7ea505fa5";
    sha256 = "1nfryd8r38amnak2fqj6g0kh79l4yzg1zfg6c2ggn0xyx1n4kks8";
  };

  patches = [
    ./0001-explicitly-initialize-elf-to-NULL-so-not-uninit-on-c.patch
  ];

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
