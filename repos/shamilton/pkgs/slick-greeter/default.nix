{ lib
, stdenv
, fetchFromGitHub
, gnome-common
, gtk
, intltool
, libcanberra_gtk3
, lightdm
, linkFarm
, pkg-config
, slick-greeter
, vala
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "slick-greeter";
  version = "master.mint20";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "slick-greeter";
    rev = version;
    sha256 = "128rdnvqwhivxpkc28zjs66hrrj17zlmxb32ni6qqandv89w3dj9";
  };

  postPatch = ''
    # replace which with command -v
    substituteInPlace autogen.sh \
      --replace which "command -v"
  '';

  preConfigure = "./autogen.sh";

  nativeBuildInputs = [ 
    wrapGAppsHook
    gnome-common
    intltool
    pkg-config
    vala
  ];

  buildInputs = [
    gtk
    (lib.getDev lightdm)
    libcanberra_gtk3
  ];

  passthru.xgreeters = linkFarm "lightdm-slick-greeter-xgreeters" [{
    path = "${slick-greeter}/share/xgreeters/slick-greeter.desktop";
    name = "slick-greeter.desktop";
  }];

  meta = with lib; {
    description = "A slick-looking LightDM greeter";
    license = licenses.gpl3Plus;
    homepage = "https://github.com/linuxmint/slick-greeter";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
