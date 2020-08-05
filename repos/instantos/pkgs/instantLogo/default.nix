{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
}:
stdenv.mkDerivation {

  pname = "instantLogo";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantLOGO";
    rev = "7224fd37aa7acbf9a8ddcb0f7b922d28ef24286c";
    sha256 = "1mal98yyc10bs91jksa8ispjnqy8rjnl9mjij345r6h7y6asxq2k";
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
