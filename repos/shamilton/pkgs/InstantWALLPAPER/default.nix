{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, InstantLOGO
, iconf
}:
stdenv.mkDerivation rec {

  pname = "instantWALLPAPER";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWALLPAPER";
    rev = "master";
    sha256 = "1ril747fiwg0lzz4slc9ndzy5an3mwnmqk6fk58pp09z5g2wjhla";
  };

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${InstantLOGO}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh
  '';
  
  installPhase = ''
    install -Dm 555 wall.sh $out/bin/wall.sh
    install -Dm 555 wallutils.sh $out/bin/wallutils.sh
  '';

  propagatedBuildInputs = [ InstantLOGO iconf ];

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
