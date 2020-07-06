{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
}:
stdenv.mkDerivation rec {

  pname = "InstantPrograms";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantOS";
    rev = "master";
    sha256 = "11d2hjjmamwxhicsxi9pdi9rds82hqf5hljbicclw1y745fygkx8";
  };
  
  installPhase = ''
    install -Dm 555 programs/instantstartmenu $out/bin/instantstartmenu
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
