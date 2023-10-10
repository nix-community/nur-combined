{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "kuroko";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "kuroko-lang";
    repo = "kuroko";
    rev = "v${version}";
    hash = "sha256-+hzgRX0T0LhAcHHBdOp8Tlo2hO2gxt6wkHjulDHdZ1Q=";
  };

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Dialect of Python with explicit variable declaration and block scoping, with a lightweight and easy-to-embed bytecode compiler and interpreter";
    homepage = "https://github.com/kuroko-lang/kuroko";
    license = licenses.mit;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
