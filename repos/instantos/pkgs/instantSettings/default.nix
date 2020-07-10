{ lib
, stdenv
, fetchFromGitHub
, instantASSIST
, instantConf
, python3
, gtk
}:
stdenv.mkDerivation {

  pname = "instantSETTINGS";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantSETTINGS";
    rev = "0e40c6cbf1748b76658443ce9c5aca8e4ceebfe5";
    sha256 = "19z508n3mc6i78c794ssxxmw8v9cx71yrzllpl7qk91dd157drxz";
  };

  postPatch = ''
    substituteInPlace mainsettings.py \
      --replace /opt/instantos/menus "${instantASSIST}/opt/instantos/menus/dm/tk.sh" \
      --replace /usr/share/instantsettings "$out/share/instantsettings" \
      --replace iconf "${instantConf}/bin/iconf"
    substituteInPlace modules/instantos/rox.sh \
      --replace /usr/share/applications "$out/share/applications"
    substituteInPlace modules/instantos/settings.py \
      --replace iconf "${instantConf}/bin/iconf"
    substituteInPlace modules/mouse/mousesettings.py \
      --replace iconf "${instantConf}/bin/iconf"
  '';
  
  installPhase = ''
    install -Dm 555 mainsettings.py $out/bin/instantsettings
    ln -s $out/bin/instantsettings $out/bin/instantos-control-center
    install -Dm 644 instantcontrolcenter.desktop $out/share/applications/instantcontrolcenter.desktop
    install -Dm 644 instantsettings.desktop $out/share/applications/instantsettings.desktop
    rm instantcontrolcenter.desktop instantsettings.desktop
    mkdir -p $out/share/instantsettings
    rm mainsettings.py
    mv * $out/share/instantsettings
  '';

  propagatedBuildInputs = [ gtk python3 instantASSIST instantConf ];

  meta = with lib; {
    description = "Simple settings app for instant-OS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantSETTINGS";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
