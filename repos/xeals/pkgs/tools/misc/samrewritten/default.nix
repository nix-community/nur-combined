{ stdenv
, fetchFromGitHub
, makeWrapper

, curl
, gnumake
, gnutls
, gtk3
, gtkmm3
, pkg-config
, yajl
}:

stdenv.mkDerivation rec {
  pname = "SamRewritten";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "PaulCombal";
    repo = pname;
    rev = "202005";
    sha256 = "0zcb6cmzk4fvbf0rkyyfvlnh9mhi0wz89parprkz6vxrj65ph1f6";
  };

  nativeBuildInputs = [ gnumake pkg-config ];
  buildInputs = [
    curl
    gnutls
    gtk3
    gtkmm3
    yajl
  ];

  NIX_CFLAGS_LINK = "-pthread";

  # FIXME: Use `make install` after the next release
  # FIXME: Get `substituteInPlace` working
  installPhase = ''
    mkdir -p $out/lib/SamRewritten/{bin,glade,assets}
    mkdir -p $out/share/icons/hicolor/{64x64,256x256}/apps
    mkdir -p $out/share/applications
    mkdir -p $out/bin
    cp bin/launch.sh bin/samrewritten bin/libsteam_api.so $out/lib/SamRewritten/bin/
    ln -s $out/lib/SamRewritten/bin/launch.sh $out/bin/samrewritten
    cp glade/main_window.glade $out/lib/SamRewritten/glade/main_window.glade
    cp assets/icon_64.png $out/share/icons/hicolor/64x64/apps/samrewritten.png
    cp assets/icon_256.png $out/share/icons/hicolor/256x256/apps/samrewritten.png
    cp assets/icon_256.png $out/lib/SamRewritten/assets/

    substitute package/samrewritten.desktop $out/share/applications/samrewritten.desktop \
      --replace /usr/bin/samrewritten $out/bin/samrewritten
  '';

  meta = with stdenv.lib; {
    description = "Steam Achievement Manager For Linux";
    homepage = "https://github.com/PaulCombal/SamRewritten";
    license = licenses.gpl3;
  };
}
