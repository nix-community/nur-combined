{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {

  pname = "instantWidgets";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantwidgets";
    rev = "70316f17a08bc160c314e51b137f29004e6f091c";
    sha256 = "sha256-icqRV9K8k+lCcMJ5lEhUYpX3WNzSOqFXnsnW68WtcJY=";
    name = "instantOS_instantWidgets";
  };

  postPatch = ''
    substituteInPlace install.conf \
      --replace /usr/share/instantwidgets "$out/share/instantwidgets"
  '';

  installPhase = ''
    mkdir -p "$out/share/instantwidgets"
    mv * "$out/share/instantwidgets"
  '';

  meta = with lib; {
    description = "instantOS widgets";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantwidgets";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
