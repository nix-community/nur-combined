{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  pkgconf,
  freetype,
  imagemagick,
  liblqr1,
  libxext,
}:

stdenv.mkDerivation rec {
  pname = "tex3ds";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hb8nncZ3AwJq6oDyvas9d9rw0RHPth1q1Chqqd8gwf4=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkgconf
  ];

  buildInputs = [
    freetype
    imagemagick
    liblqr1
    libxext
  ];

  preConfigure = ''
    bash ./autogen.sh
  '';

  meta = with lib; {
    description = "3DS Texture Conversion";
    homepage = "https://github.com/devkitPro/tex3ds";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
