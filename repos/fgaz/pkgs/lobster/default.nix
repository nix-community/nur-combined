{ stdenv
, fetchFromGitHub
, cmake
, libGL
, xorg
}:

stdenv.mkDerivation rec {
  pname = "lobster";
  version = "unstable-2020-01-18";
  src = fetchFromGitHub {
    owner = "aardappel";
    repo = pname;
    rev = "45af282f78689c83f4360636e3b258a491d9d3f3";
    sha256 = "0q9m7iysfarg8v8h7mgn73biimkxxqiqadkk937fj367zbpgw94n";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    libGL
    xorg.libX11
    xorg.libXext
  ];
  preConfigure = "cd dev";
  enableParallelBuilding = true;
  meta = with stdenv.lib; {
    homepage = "http://strlen.com/lobster";
    description = "The Lobster programming language";
    longDescription = ''
      Lobster is a programming language that tries to combine the advantages of
      very static typing and memory management with a very lightweight,
      friendly and terse syntax, by doing most of the heavy lifting for you.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.linux;
  };
}

