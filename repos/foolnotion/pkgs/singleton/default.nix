{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "singleton";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "jimmy-park";
    repo = "singleton";
    rev = "${version}";
    hash = "sha256-gLypWP5J+Moo73kux19k1LEXyDHulyC6tHxLYgC8ZJE=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DSINGLETON_INSTALL=ON"
  ];

  meta = with lib; {
    description = "Implement thread-safe singleton classes using CRTP";
    homepage = "https://github.com/jimmy-park/singleton";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
