{ stdenv, lib, fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  name = "cc65-${version}";
  version = "git-20200221";

  src = fetchFromGitHub {
    owner = "cc65";
    repo = "cc65";
    rev = "e2c664860781747eb247770bc766c7f0c5351a62";
    sha256 = "0wq4201wdqc6fihlrrfyhvqhafbnav471gbz2xh3shsgaxvrscy6";
  };

  patches = [  ];
  buildInputs = [  ];
  configureFlags = [  ];
  makeFlags = [ "PREFIX=$(out)" "all" ];

  meta = with lib; {
    description = "a complete cross development package for 6502/65C02 systems, including a powerful macro assembler, a C compiler, linker, librarian and several other tools";
    homepage    = https://cc65.github.io;
    license     = licenses.zlib;
    maintainers = with maintainers; [ tokudan ];
  };
}

