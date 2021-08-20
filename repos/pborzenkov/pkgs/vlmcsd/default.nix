{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "vlmcsd";
  version = "1113";

  src = fetchFromGitHub {
    owner = "Wind4";
    repo = "vlmcsd";
    rev = "svn${version}";
    sha256 = "19qfw4l4b5vi03vmv9g5i7j32nifvz8sfada04mxqkrqdqxarb1q";
  };

  installPhase = ''
    mkdir -p $out
    cp -a bin $out/

    mkdir -p $out/share/man/man{1,5,7,8}
    install man/{vlmcs,vlmcsdmulti}.1 $out/share/man/man1
    install man/vlmcsd.ini.5 $out/share/man/man5
    install man/{vlmcsd,vlmcsd-floppy}.7 $out/share/man/man7
    install man/vlmcsd.8 $out/share/man/man8
  '';

  meta = with lib; {
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = with licenses; [ free ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
