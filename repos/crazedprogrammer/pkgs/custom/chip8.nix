{ stdenv, fetchFromGitHub, SDL2 }:

stdenv.mkDerivation rec {
  name = "chip8";
  version = "2018-06-23";

  src = fetchFromGitHub {
    owner = "wernsey";
    repo = "chip8";
    rev = "4af7ee733bc57415e4bbe302d2b83da2b2b35e67";
    sha256 = "0jkwvj4dfhvjd53hd5ywm2cdv1dzmd0m3cbfa0099dfbccf0pi7y";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 c8asm $out/bin
    install -m 755 c8dasm $out/bin
    # Do not install the chip8 interpreter. It is broken on Astrododge.
    #install -m 755 chip8 $out/bin
  '';

  buildInputs = [ SDL2 ];
  enableParallelBuilding = true;
}
