{ stdenvNoCC, fetchFromGitHub, perl }:

stdenvNoCC.mkDerivation rec {
  pname = "urxvt-xresources-256";
  version = "2017-07-17";
  src = fetchFromGitHub {
    owner = "roliga";
    repo = pname;
    rev = "09c3b2f156035cf73e8c81d29e0917020bae1380";
    sha256 = "1y43pvyh4dnv2c8zqkhjds1rhgfz3ykxfqm4rzyyv4glv7b7jz2v";
  };

  dontPatchShebangs = true;
  #buildInputs = [ perl ];

  installPhase = ''
    install -Dm0755 -t $out/lib/urxvt/perl xresources-256
  '';
}
