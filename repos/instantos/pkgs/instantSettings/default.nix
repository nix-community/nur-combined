{ lib
, stdenv
, fetchFromGitHub
, buildPythonApplication
, instantAssist
, instantConf
, instantWallpaper
, arandr
, atk
, autorandr
, blueman
, gdk-pixbuf
, gnome-disk-utility
, gobject-introspection
, lxappearance-gtk3
, neovim
, pango
, pavucontrol
, pygobject3
, st
, firaCodeNerd
, system-config-printer
, wrapGAppsHook
, xfce4-power-manager
}:
let
  pyModuleDeps = [
    pygobject3
  ];
  gnomeDeps = [
    wrapGAppsHook 
    gobject-introspection
    pango
    gdk-pixbuf
    atk
  ];
in
buildPythonApplication {

  pname = "instantSettings";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "instantSETTINGS";
    rev = "d17718ff2d9eedfee093c3d7efa41f24ab13d861";
    sha256 = "1n8lvz4jn4b0476rb45x5x8ps0041l3nsjvdvkxhkb3sv9s8scwp";
    name = "instantOS_instantSettings";
  };

  postPatch = ''
    substituteInPlace instantSETTINGS/mainsettings.py \
      --replace /opt/instantos/menus "${instantAssist}/opt/instantos/menus/dm/tk.sh" \
      --replace "\"iconf" "\"${instantConf}/bin/iconf" \
      --replace instantwallpaper "${instantWallpaper}/bin/instantwallpaper" \
      --replace /usr/share/instantsettings "$out/share/instantsettings" \
      --replace "st " "${st}/bin/st \
      --replace arandr "${arandr}/bin/arandr" \
      --replace autorandr "${autorandr}/bin/autorandr" \
      --replace blueman-assistant "${blueman}/bin/blueman-assistant \
      --replace gnome-disks "${gnome-disk-utility}/bin/gnome-disks" \
      --replace lxappearance "${lxappearance-gtk3}/bin/lxappearance" \
      --replace nvim "${neovim}/bin/nvim" \
      --replace pavucontrol "${pavucontrol}/bin/pavucontrol" \
      --replace system-config-printer "${system-config-printer}/bin/system-config-printer" \
      --replace xfce4-power-manager-settings "${xfce4-power-manager}/bin/xfce4-power-manager-settings"
    substituteInPlace modules/instantos/rox.sh \
      --replace /usr/share/applications "$out/share/applications"
    substituteInPlace modules/instantos/settings.py \
      --replace "\"iconf" "\"${instantConf}/bin/iconf"
    substituteInPlace modules/mouse/mousesettings.py \
      --replace "\"iconf" "\"${instantConf}/bin/iconf"
  '';

  postInstall = ''
    install -Dm 644 instantSETTINGS/mainsettings.glade "$out/share/instantsettings/mainsettings.glade"
    mkdir -p "$out/share/applications"
    cp instantSETTINGS/*.desktop "$out/share/applications"
    ln -s "$out/bin/mainsettings" "$out/bin/instantsettings"
    mv modules "$out/share/instantsettings"
  '';

  nativeBuildInputs = gnomeDeps;
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps ++
  [
    instantAssist
    instantConf
    instantWallpaper
    arandr
    atk
    autorandr
    blueman
    gdk-pixbuf
    gnome-disk-utility
    gobject-introspection
    lxappearance-gtk3
    neovim
    pango
    pavucontrol
    pygobject3
    st
    system-config-printer
    wrapGAppsHook
    xfce4-power-manager
    firaCodeNerd
  ];

  meta = with lib; {
    description = "Simple settings app for instant-OS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantSETTINGS";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
