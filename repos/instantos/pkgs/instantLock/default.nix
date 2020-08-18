{ stdenv, lib, fetchurl, writeText
, fetchFromGitHub
, argtable3, glib, wrapGAppsHook, pkg-config
, xorgproto, libX11, libXext, libXrandr, libXinerama
, instantMenu
, conf ? null }:

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "instantLock";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "instantLOCK";
    rev = "ae4f32f4ee281f6926ae9efe3b6593fb32139638";
    sha256 = "07r7d1xhs82cdslsqb05zhzn29hi8j32x478nbvjyplwsdxzv9b0";
  };

  nativeBuildInputs = [ wrapGAppsHook pkg-config ];
  buildInputs = [ argtable3 glib xorgproto libX11 libXext libXrandr libXinerama ];
  propagatedBuildInputs = [ instantMenu ];

  installFlags = [ "DESTDIR=\${out}" "PREFIX=" ];

  postPatch = ''
    sed -i '/chmod u+s/d' Makefile
    substituteInPlace config.def.h \
      --replace 'group = "nobody"' 'group = "nogroup"'
    sed -n "5,6p"
  ''
  ;

  preBuild = optionalString (conf != null) ''
    cp ${writeText "config.def.h" conf} config.def.h
  '';

  meta = with stdenv.lib; {
    description = "Screen lock manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantLOCK";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
