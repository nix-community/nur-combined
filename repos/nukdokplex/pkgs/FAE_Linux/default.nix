{ stdenv, fetchFromGitHub, lib, cmake, ... }: stdenv.mkDerivation rec {
  pname = "FAE_Linux";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "UnlegitSenpaii";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6+5ooYFYRImOJKrTApUCrpKiSYXbEugnG6rZeKmaGsY=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    mkdir -p $out
    cp -a out/bin $out
  '';

  meta = {
    homepage = "https://github.com/UnlegitSenpaii/FAE_Linux";
    description = "FAE_Linux (Factorio Achievement Enabler for Linux) allows you to unlock Steam achievements while playing the game with mods on Linux.";
    license = with lib.licenses; [ asl20 ];
    platforms = [ "x86_64-linux" ];
  };
}
