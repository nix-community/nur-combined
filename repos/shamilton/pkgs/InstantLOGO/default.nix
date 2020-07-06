{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
}:
stdenv.mkDerivation rec {

  pname = "InstantLOGO";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantLOGO";
    rev = "master";
    sha256 = "073jgqdwz01755awjx882w9i5lwwqcjzwklcwwc3kfa52rcpd9bh";
  };

  installPhase = ''
    install -Dm 644 wallpaper/readme.jpg $out/share/backgrounds/readme.jpg
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
