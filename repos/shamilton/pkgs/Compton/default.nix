{ lib
, stdenv
, fetchFromGitHub
, dbus
, gnumake
, libX11
, libXcomposite
, libXdamage
, libXext
, libXinerama
, libXrandr
, libXrender
, libconfig
, libdrm
, libglvnd
, linuxHeaders
, pcre
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "Compton";
  version = "0.1_beta2";

  src = fetchFromGitHub {
    owner = "tryone144";
    repo = "compton";
    rev = "v${version}";
    sha256 = "0v65viilhnd2xgvmdpzc1srxszcg8kj1vhi5gy9292j48w0s2fx1";
  };

  patches = [ ./dont-build-doc.patch ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "PREFIX ?= /usr" "PREFIX ?= $out"
    rm -rf man
  '';

  nativeBuildInputs = [ gnumake pkg-config ];
  buildInputs = [
    libX11
    libXcomposite
    libXdamage
    libXrender
    libXext
    libXrandr
    libXinerama
    libconfig
    dbus
    libglvnd
    libdrm
    pcre
  ];

  meta = with lib; {
    description = "Compositor for X11";
    license = licenses.mit;
    homepage = "https://github.com/tryone144/compton";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
