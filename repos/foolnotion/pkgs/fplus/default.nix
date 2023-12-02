{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "FunctionalPlus";
  version = "0.2.20-p0";

  src = fetchFromGitHub {
    owner = "Dobiasd";
    repo = "FunctionalPlus";
    rev = "v${version}";
    hash = "sha256-PKd3gx63VTxyq1q0v7WaKXVA0oICpZQfVsKsgUml9wk=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Functional Programming Library for C++";
    homepage = "https://github.com/Dobiasd/FunctionalPlus";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
