{ stdenv, fetchFromGitHub, libnl }:

stdenv.mkDerivation rec {
  pname = "nltrace";
  version = "2018-03-18";

  src = fetchFromGitHub {
    owner = "socketpair";
    repo = pname;
    rev = "1f6eae759c85a7e04c47dc203d282bad96f927d5";
    sha256 = "1ifmg7x24lry4xfdxkvgv67a8kv8nlkd841hxim5f4m2aw1bb0r4";
  };

  buildInputs = [ libnl ];

  postPatch = ''
    substituteInPlace Makefile --replace /usr/include ${libnl.dev}/include
  '';

  installPhase = ''
    install -Dm755 nltrace -t $out/bin
    install -Dm755 preload.so -t $out/lib
  '';

  meta = with stdenv.lib; {
     description = "Netlink tracing tool";
     # dunno license, doesn't seem to say :(
     maintainers = with maintainers; [ dtzWill ];
  };
}
