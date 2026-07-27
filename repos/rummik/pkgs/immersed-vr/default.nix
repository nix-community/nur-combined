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

  libvaDriverName ? "iHD"
}:

let

  curl_ =
    (curl.override {
      gnutlsSupport = true;
      sslSupport = false;
    })
    .overrideAttrs (old: rec {
      patches = [
        ./curl-gnutls-3.patch
      ];

      configureFlags =
        old.configureFlags ++ [
          "--enable-versioned-symbols"
        ];
    });

in

stdenv.mkDerivation rec {
  pname = "immersed-vr";
  version = "1.4.0";

  src = fetchurl {
    url = "http://206.189.168.203:8080/pool/main/i/immersed/Immersed_${version}-0_amd64.deb";
    sha256 = "0njrq4ax8yf59xa3klbd20am8k2qipz188za1m3jpnqcm70b5b4v";
  };

  desktopItem = makeDesktopItem {
    name = "immersed-vr";
    exec = "Immersed %U";
    icon = "immersed";
    comment = "An immersive VR desktop experience";
    desktopName = "Immersed VR";
    categories = "Utility";
  };

  nativeBuildInputs = [ dpkg makeWrapper autoPatchelfHook patchelfUnstable ];

  buildInputs = [
    stdenv.cc.cc
    cairo
    curl_.out
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
    mkdir -p $out/{bin,share,lib}
    cp -r usr/{local/bin,share} $out
  '';

  postFixup = /* sh */ ''
    wrapProgram $out/bin/Immersed \
      --argv0 Immersed \
      --set-default LIBVA_DRIVER_NAME ${libvaDriverName} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}:$out/lib \
      --run "${proot}/bin/proot -b $out/bin/immersed-res:/usr/local/bin/immersed-res bash -c 'eval \$@' - \\"
  '';

  meta = with stdenv.lib; {
    description = "An immersive VR desktop experience";
    homepage = "https://immersedvr.com";
    license = licenses.unfree;
    #maintainers = with maintainers; [ rummik ];
    platforms = [ "x86_64-linux" ];
  };
}
