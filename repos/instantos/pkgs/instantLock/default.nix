{ stdenv, fetchurl, writeText
, fetchFromGitHub
, xorgproto, libX11, libXext, libXrandr, libXinerama
, instantMenu
, conf ? null }:

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "instantLock";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantLOCK";
    rev = "88fa0c04ab13b1d3a0fe2d565e4ee26c363269dc";
    sha256 = "11cr991ygxx2qnldpq01b3qa87711171rwr142im695p3digxwz4";
    name = "instantOS_instantLock";
  };

  buildInputs = [ xorgproto libX11 libXext libXrandr libXinerama ];
  propagatedBuildInputs = [ instantMenu ];

  installFlags = [ "DESTDIR=\${out}" "PREFIX=" ];

  postPatch = "sed -i '/chmod u+s/d' Makefile";

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
