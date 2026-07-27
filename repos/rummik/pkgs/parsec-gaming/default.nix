{ stdenv, lib, fetchurl, dpkg,
  autoPatchelfHook, makeDesktopItem, makeWrapper, patchelfUnstable,
  proot,
  cairo,
  curl,
  fontconfig,
  gdk-pixbuf,
  glib,
  glibc,
  gnutls,
  gtk3,
  libgcrypt,
  libva,
  libva1,
  libzip,
  pango,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "parsec-gaming";
  version = "2020-04-20";

  src = fetchurl {
    url = "https://builds.parsecgaming.com/package/parsec-linux.deb";
    sha256 = "1hfdzjd8qiksv336m4s4ban004vhv00cv2j461gc6zrp37s0fwhc";
  };

  nativeBuildInputs = [ dpkg makeWrapper autoPatchelfHook patchelfUnstable ];

  buildInputs = [
    stdenv.cc.cc
    cairo
    fontconfig
    gdk-pixbuf
    glib
    glibc
    gtk3
    libgcrypt
    libva
    libva1
    libzip
    pango
    xorg.libSM
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXtst
    xorg.libXxf86vm
  ];

  dontCheck = true;
  dontConfigure = true;
  #dontPatchElf = true;
  #dontWrapGApps = true;

  unpackPhase = /* sh */ ''
    dpkg-deb -x $src .
  '';

  installPhase = /* sh */ ''
  ls -R
    mkdir -p $out/{bin,share}
    cp -r usr/{bin,share} $out
  '';

 postFixup = /* sh */ ''
   wrapProgram $out/bin/parsecd \
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}:$out/share/parsec/skel
 '';

  meta = with stdenv.lib; {
    description = "An immersive VR desktop experience";
    homepage = "https://immersedvr.com";
    license = licenses.unfree;
    #maintainers = with maintainers; [ rummik ];
    platforms = [ "x86_64-linux" ];
  };
}
