{ lib
, stdenv
, fetchFromGitHub
, gnumake
}:
stdenv.mkDerivation {

  pname = "instantLogo";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantLOGO";
    rev = "014673c0d7cc62a35b639bb308f23d2c8d8b74a5";
    sha256 = "Bu/z06GxwFQy+oB+rHeWi6SZgpkf4r7TgXx8S0djvDM=";
    name = "instantOS_instantLogo";
  };

  installPhase = ''
    install -Dm 644 wallpaper/readme.jpg $out/share/backgrounds/readme.jpg
  '';

  meta = with lib; {
    description = "Logo assets of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
