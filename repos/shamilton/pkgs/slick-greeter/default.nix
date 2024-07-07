{ lib
, stdenv
, fetchFromGitHub
, slick-greeter
, python3
, gnome-common
, gtk3
, intltool
, libcanberra-gtk3
, xapps
, lightdm
, linkFarm
, pkg-config
, vala
, wrapGAppsHook
, gobject-introspection
}:
let
  pythonEnv = python3.withPackages (ps: with ps; [ pygobject3 ]);
in
stdenv.mkDerivation rec {

  pname = "slick-greeter";
  version = "master.mint22";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "slick-greeter";
    rev = version;
    sha256 = "sha256-Q37CprukHvDRBcuPbfusKg2DY+JCwmjVX1+KnfSH2iw=";
  };

  patches = [ ./install-to-sbin-and-to-bin.patch ];

  nativeBuildInputs = [ 
    gnome-common
    intltool
    pkg-config
    vala
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    (lib.getDev lightdm)
    libcanberra-gtk3
    xapps
  ];

  propagatedBuildInputs = [
    pythonEnv
  ];

  postPatch = ''
    # replace which with command -v 
    substituteInPlace autogen.sh \
      --replace which "command -v"
    substituteInPlace src/slick-greeter.vala \
      --replace "/usr/bin/slick-greeter-check-hidpi" "$out/bin/slick-greeter-check-hidpi" \
      --replace "/usr/bin/slick-greeter-set-keyboard-layout" "$out/bin/slick-greeter-set-keyboard-layout"
    substituteInPlace files/usr/bin/slick-greeter-check-hidpi \
      --replace "/usr/bin/python3" "${pythonEnv}/bin/python3"
    substituteInPlace files/usr/bin/slick-greeter-set-keyboard-layout \
      --replace "/usr/bin/python3" "${python3}/bin/python3"
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  postInstall = ''
    install -Dm 555 files/usr/bin/slick-greeter-check-hidpi "$out/bin/slick-greeter-check-hidpi"
    install -Dm 555 files/usr/bin/slick-greeter-set-keyboard-layout "$out/bin/slick-greeter-set-keyboard-layout"
  '';

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
