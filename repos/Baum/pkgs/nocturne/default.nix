{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  python3,
  gtk4,
  libadwaita,
  libsecret,
  gst_all_1,
  blueprint-compiler,
  meson,
  ninja,
  desktop-file-utils,
  shared-mime-info,
  wrapGAppsHook4,
  gobject-introspection,
  xdg-user-dirs,

}:
let
  gtk4new = (
    (gtk4.overrideAttrs (old: rec {
      version = "4.22.1";
      nativeBuildInputs = old.nativeBuildInputs ++ [ shared-mime-info ];
      src = fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "gtk";
        tag = version;
        hash = "sha256-MTW5qCq3Sj0aSGPfGQphN1t4cs4rPbLPBc7BRgOktDE=";
      };
    }))
  );
  libadwaitaNew = (
    (libadwaita.overrideAttrs (_: rec {
      version = "1.9.0";
      src = fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "libadwaita";
        tag = version;
        hash = "sha256-JAKP8CjLCKGZvHoB26ih/J3xAru4wiVf/ObG0L8r4pY=";
      };
    })).override
      {
        gtk4 = gtk4new;
      }
  );
in
stdenv.mkDerivation (finalAttrs: {
  version = "0.6.0";
  pname = "Nocturne";
  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Nocturne";
    rev = "${finalAttrs.version}";
    hash = "sha256-V4l7Bxgb/wBh7J/c0zJlN9TeMR68T/1CJpd5r/HLLyE=";
  };

  buildInputs = [
    gtk4new
    xdg-user-dirs
    gobject-introspection
    libadwaitaNew
    libsecret
    gst_all_1.gstreamer
    (python3.withPackages (
      py: with py; [
        requests
        colorthief
        favicon
        (callPackage ../mpris-server { })
        mutagen
      ]
    ))
  ];

  nativeBuildInputs = [
    wrapGAppsHook4
    (blueprint-compiler.override {
      libadwaita = libadwaitaNew;
    })
    meson
    ninja
    desktop-file-utils
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix PATH : ${lib.getBin xdg-user-dirs}/bin
    )
  '';

  meta = with lib; {
    description = "An Adwaita Music Player / Library Manager ";
    homepage = "https://github.com/Jeffser/Nocturne";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
})
