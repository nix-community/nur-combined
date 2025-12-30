{
  lib,
  pkgs,
  stdenv,
}:

stdenv.mkDerivation rec {
  meta = with lib; {
    description = "Graphical utility to review and modify Flatpak permissions";
    homepage = "https://github.com/tchx84/Flatseal";
    license = licenses.gpl3Plus;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    mainProgram = "com.github.tchx84.Flatseal";
  };

  pname = "flatseal";
  version = "2.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "tchx84";
    repo = "Flatseal";
    rev = "v${version}";
    sha256 = "sha256-vIlhHs9prg+FRruf0VBeUVWvnLucqcn477qtcdiV/9A=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = with pkgs; [
    gjs
    glib
    gtk4
    libadwaita
    webkitgtk_6_0
    appstream
    gobject-introspection
    glib-networking
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix GI_TYPELIB_PATH : "${
        lib.makeSearchPath "lib/girepository-1.0" (
          with pkgs;
          [
            glib
            gtk4
            libadwaita
            webkitgtk_6_0
            appstream
            gobject-introspection
            glib-networking
          ]
        )
      }"
    )
  '';
}