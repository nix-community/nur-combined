{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "chelf-${version}";
  version = "2018-10-26";

  src = fetchFromGitHub {
    owner = "Gottox";
    repo = "chstk";
    rev = "eecd272be6494f542978160c19f1ba9349d5bce1";
    sha256 = "1iappq7nm72pa9kbdi0vxj1sxxwrcpml99iq5kxrdjspz6kgvxvz";
  };

  patches = [
    ./0001-explicitly-initialize-elf-to-NULL-so-not-uninit-on-c.patch
    ./0002-Fix-inverted-size-check.patch
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv chelf $out/bin/chelf
  '';

  meta = with stdenv.lib; {
    description = "change or display the stack size of an ELF binary";
    homepage = https://github.com/Gottox/chstk;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
