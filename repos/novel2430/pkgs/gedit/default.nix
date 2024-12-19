{ stdenv
, lib
, meson
, mesonEmulatorHook
, fetchurl
, python3
, pkg-config
, gtk3
, glib
, libpeas
, libxml2
, gsettings-desktop-schemas
, wrapGAppsHook3
, gtk-doc
, gobject-introspection
, docbook-xsl-nons
, ninja
, gnome
, gspell
, perl
, itstool
, desktop-file-utils
, vala
, fetchFromGitHub
, webkitgtk_4_0
, libsoup 
, python312Packages
, pandoc
, makeWrapper
, cmake
, dbus
, icu
, gettext
, atk
, cairo
, pango
, fribidi
, shared-mime-info
, xvfb-run
, texliveSmall
}:
let
  gedit-markdown-preview = fetchFromGitHub {
    owner = "maoschanz";
    repo = "gedit-plugin-markdown_preview";
    rev = "1c3da56db6331638f3935ac18fb82b1ed2c16960";
    sha256 = "sha256-Hqi0/019pYlGpysZDMmxbwFJ28znlNXkEZA6tjvTVDQ=";
  };
  amtk = stdenv.mkDerivation rec {
    pname = "amtk";
    version = "5.6.1";

    outputs = [ "out" "dev" "devdoc" ];

    src = fetchurl {
      url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
      sha256 = "1QEVuFyHKqwpaTS17nJqP6FWxvWtltJ+Dt0Kpa0XMig=";
    };
    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      dbus
      gobject-introspection
      gtk-doc
      docbook-xsl-nons
    ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
      mesonEmulatorHook
    ];
    buildInputs = [
      gtk3
    ];
  };
  tepl = stdenv.mkDerivation rec {
    pname = "tepl";
    version = "6.4.0";

    outputs = [ "out" "dev" "devdoc" ];

    src = fetchurl {
      url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
      sha256 = "XlayBmnQzwX6HWS1jIw0LFkVgSLcUYEA0JPVnfm4cyE=";
    };

    strictDeps = true;
    nativeBuildInputs = [
      meson
      ninja
      gobject-introspection
      pkg-config
      gtk-doc
      docbook-xsl-nons
    ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
      mesonEmulatorHook
    ];

    buildInputs = [
      icu
    ];

    propagatedBuildInputs = [
      amtk
      gtksourceview4
      gtk3
    ];
  };
  gtksourceview4 = stdenv.mkDerivation (finalAttrs: {
    pname = "gtksourceview";
    version = "4.8.4";

    outputs = [ "out" "dev" ];

    src = let
      inherit (finalAttrs) pname version;
    in fetchurl {
      url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
      sha256 = "fsnRj7KD0fhKOj7/O3pysJoQycAGWXs/uru1lYQgqH0=";
    };

    patches = [
      # By default, the library loads syntaxes from XDG_DATA_DIRS and user directory
      # but not from its own datadr (it assumes it will be in XDG_DATA_DIRS).
      # Since this is not generally true with Nix, let’s add $out/share unconditionally.
      ./4.x-nix_share_path.patch
    ];

    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      gettext
      perl
      gobject-introspection
      vala
    ];

    buildInputs = [
      atk
      cairo
      glib
      pango
      fribidi
      libxml2
    ];

    propagatedBuildInputs = [
      # Required by gtksourceview-4.0.pc
      gtk3
      # Used by gtk_source_language_manager_guess_language
      shared-mime-info
    ];

    nativeCheckInputs = [
      xvfb-run
      dbus
    ];

    postPatch = ''
      # https://gitlab.gnome.org/GNOME/gtksourceview/-/merge_requests/295
      # build: drop unnecessary vapigen check
      substituteInPlace meson.build \
        --replace "if generate_vapi" "if false"
    '';
  });
  libs = [
    glib
    gsettings-desktop-schemas
    gspell
    gtk3
    amtk
    tepl
    gtksourceview4
    libpeas
    webkitgtk_4_0
    libsoup
    python312Packages.markdown
    python312Packages.pygments
    python312Packages.pymdown-extensions
    pandoc
    texliveSmall
  ];
in
stdenv.mkDerivation rec {
  pname = "gedit";
  version = "44.2";

  outputs = [ "out" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gedit/${lib.versions.major version}/gedit-${version}.tar.xz";
    sha256 = "sha256-O7sbN3XUwnfa9UqqtEsOuDpOsfCfA5GAAEHJ5WiT7BE=";
  };

  patches = [
    # We patch gobject-introspection and meson to store absolute paths to libraries in typelibs
    # but that requires the install_dir is an absolute path.
    ./correct-gir-lib-path.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    desktop-file-utils
    itstool
    libxml2
    meson
    ninja
    perl
    pkg-config
    python3
    vala
    wrapGAppsHook3
    gtk-doc
    gobject-introspection
    docbook-xsl-nons
    cmake
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = libs;

  postPatch = ''
    chmod +x build-aux/meson/post_install.py
    chmod +x plugins/externaltools/scripts/gedit-tool-merge.pl
    patchShebangs build-aux/meson/post_install.py
    patchShebangs plugins/externaltools/scripts/gedit-tool-merge.pl
  '';

  # Reliably fails to generate gedit-file-browser-enum-types.h in time
  enableParallelBuilding = false;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gedit";
    };
  };

  postInstall = ''
    # Install gedit-plugin-markdown-preview plugin
    # Make Scheme Dir
    mkdir -p $out/share/glib-2.0/schemas
    install_dir="$out/lib/gedit/plugins"
    schemas_dir="$out/share/glib-2.0/schemas"

    echo "Installing setting schemas in ''$schemas_dir"
    cp ${gedit-markdown-preview}/org.gnome.gedit.plugins.markdown_preview.gschema.xml ''$schemas_dir
    glib-compile-schemas ''$schemas_dir

    echo "Installing plugin files in ''$install_dir"
    cp ${gedit-markdown-preview}/markdown_preview.plugin ''$install_dir/markdown_preview.plugin
    cp -r ${gedit-markdown-preview}/markdown_preview ''$install_dir/
    substituteInPlace ''$install_dir/markdown_preview/utils.py --replace-fail "import importlib, shutil, os, gi" "import importlib.util, shutil, os, gi"

    echo "Done."

    # Wrapper
    mv $out/bin/gedit $out/bin/gedit-base
    makeWrapper $out/bin/gedit-base $out/bin/gedit \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs} \
      --prefix PYTHONPATH : "${python312Packages.markdown}/lib/python3.12/site-packages:${python312Packages.pygments}/lib/python3.12/site-packages:${python312Packages.pymdown-extensions}/lib/python3.12/site-packages" \
      --prefix GI_TYPELIB_PATH : "${webkitgtk_4_0}/lib/girepository-1.0:${libsoup}/lib/girepository-1.0" \
      --prefix PATH : "${pandoc}/bin:${texliveSmall}/bin";

  '';

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/World/gedit/gedit";
    description = "Former GNOME text editor (With Markdown Preview Plugin)";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "gedit";
  };
}
