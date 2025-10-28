{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "nanobench";
  version = "4.3.11";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "nanobench";
    rev = "e4327893194f06928012eb81cabc606c4e4791ac";
    sha256 = "sha256-WZmlZS9nQ/mN+IYyuatrPAF1Nbjzm921qQYcxYtzbKs=";
  };

  nativeBuildInputs = [ cmake ];

  patches = [ ./fix_errors.patch ];

  cmakeFlags = [ "-DNB_sanitizer=OFF" ];

  meta = with lib; {
    description = "Platform independent microbenchmarking library for C++11/14/17/20";
    homepage = "https://nanobench.ankerl.com";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
