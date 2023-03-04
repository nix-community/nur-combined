{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gjs,
  graphene,
  gtk4,
  gtksourceview5,
  harfbuzz,
  libadwaita,
  meson,
  ninja,
  pango,
  wrapGAppsHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "commit";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-nnjHuE7MzCuoPfCb4MA00BIzLPbhgR6mbeWYagmNjME=";
  };

  patches = [
    ./fix-gjs-path.patch
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    wrapGAppsHook
  ];

  buildInputs = [
    gjs
    graphene
    gtk4
    libadwaita
    pango
  ];

  postPatch = ''
    for file in re.sonny.Commit src/re.sonny.Commit; do
      substituteAllInPlace $file
    done
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # Typelibs
      --prefix GI_TYPELIB_PATH : "${lib.makeSearchPath "lib/girepository-1.0" [
      gdk-pixbuf
      graphene
      gtk4
      gtksourceview5
      harfbuzz
      libadwaita
      pango.out
    ]}"
    )
  '';

  meta = with lib; {
    mainProgram = "re.sonny.Commit";
    description = "Commit message editor";
    longDescription = ''
      Commit is an editor that helps you write better Git and Mercurial commit messages.
    '';
    homepage = "https://github.com/sonnyp/Commit";
    license = licenses.gpl3Plus;
  };
}
