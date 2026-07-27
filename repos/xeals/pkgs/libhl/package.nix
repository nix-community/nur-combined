{ stdenv
, lib
, fetchFromGitHub

, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "libhl";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "xant";
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "05mrp5rmki0wghdpmcgvsi8lqhfshifbmhp1qlkd89fb2srq91lf";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  patches = [ ./fix-link.patch ];

  preInstall = ''
    mkdir -p $out/include $out/lib
  '';

  meta = with lib; {
    homepage = "https://github.com/xant/libhl";
    description = "Simple and fast C library implementing a thread-safe API to manage hash-tables, linked lists, lock-free ring buffers and queues ";
    license = licenses.lgpl3;
    platforms = platforms.all;
    broken = true;
  };
}
