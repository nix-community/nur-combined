{ stdenv, fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  name = "cbmbasic${version}";
  version = "git-20141207";

  src = fetchFromGitHub {
    owner = "mist64";
    repo = "cbmbasic";
    rev = "89093eba090d6e1c2d2b6e1cb1616dba0ce9c7f6";
    sha256 = "0ilhpl9d1fv4mvrxylnmrjynwsvy8cbdgjd0p4s15hma00834n7h";
  };

  patches = [  ];
  buildInputs = [  ];
  configureFlags = [  ];
  makeFlags = [  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m 0555 cbmbasic $out/bin
    '';

  meta = with stdenv.lib; {
    description = "Commodore BASIC V2 as a scripting language";
    homepage    = https://github.com/mist64/cbmbasic;
    license     = licenses.unfree;
    maintainers = with maintainers; [ tokudan ];
  };
}

