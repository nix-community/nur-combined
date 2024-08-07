{ stdenv
, fetchFromGitLab
, meson
, ninja
, wrapGAppsHook3
, pkg-config
, desktop-file-utils
, appstream-glib
, python3Packages
, glib
, gobject-introspection
, gtk3
, webkitgtk
, glib-networking
, adwaita-icon-theme
, gspell
, texliveMedium
, shared-mime-info
, libhandy
, fira
, sassc
,
}:

let
  pythonEnv = python3Packages.python.withPackages (
    p: with p; [
      regex
      setuptools
      levenshtein
      pyenchant
      pygobject3
      pycairo
      pypandoc
      chardet
    ]
  );
in
stdenv.mkDerivation rec {
  pname = "apostrophe";
  version = "2.6.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = pname;
    domain = "gitlab.gnome.org";
    rev = "v${version}";
    sha256 = "sha256-RBrrG1TO810LidIelYGNaK7PjDq84D0cA8VcMojAW3M=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream-glib
    wrapGAppsHook3
    sassc
    gobject-introspection
  ];

  buildInputs = [
    glib
    pythonEnv
    gtk3
    adwaita-icon-theme
    webkitgtk
    gspell
    texliveMedium
    glib-networking
    libhandy
  ];

  postPatch = ''
    substituteInPlace data/media/css/web/base.css                                        \
      --replace 'url("/app/share/fonts/FiraSans-Regular.ttf") format("ttf")'             \
                'url("${fira}/share/fonts/opentype/FiraSans-Regular.otf") format("otf")' \
      --replace 'url("/app/share/fonts/FiraMono-Regular.ttf") format("ttf")'             \
                'url("${fira}/share/fonts/opentype/FiraMono-Regular.otf") format("otf")'

    patchShebangs --build build-aux/meson_post_install.py
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$out/lib/python${pythonEnv.pythonVersion}/site-packages/"
      --prefix PATH : "${texliveMedium}/bin"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

  # meta = with lib; {
  #   homepage = "https://gitlab.gnome.org/World/apostrophe";
  #   description = "A distraction free Markdown editor for GNU/Linux";
  #   license = licenses.gpl3;
  #   platforms = platforms.linux;
  #   maintainers = [ maintainers.sternenseemann ];
  #   mainProgram = "apostrophe";
  # };
}
