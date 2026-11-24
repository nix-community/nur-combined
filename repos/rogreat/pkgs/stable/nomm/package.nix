{
  fetchFromGitHub,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  lib,
  libadwaita,
  libnotify,
  p7zip,
  python3Packages,
  unrar-free,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nomm";
  version = "0.15.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "NOMM-Team";
    repo = "nomm-app";
    tag = finalAttrs.version;
    hash = "sha256-npDF4mISfJr/6x9TRRvdlcw7RO5nGefN7MIsBejtNCQ=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    gettext
  ];

  buildInputs = [
    libadwaita
    libnotify
  ];

  dependencies = with python3Packages; [
    packaging
    pygobject3
    pyyaml
    rarfile
    requests
    vdf
    dulwich
  ];

  postPatch = ''
    substituteInPlace src/nomm/gui/dashboard.py src/nomm/core/archive_manager.py \
        --replace-fail '/app/bin/unrar' "${lib.getExe unrar-free}"
  '';

  postInstall =
    # Flatpak
    # https://github.com/NOMM-Team/nomm-app/blob/main/build/flatpak/moe.nomm.Nomm.yaml
    ''
      # Install desktop file
      install -D build/flatpak/moe.nomm.Nomm.desktop $out/share/applications/moe.nomm.Nomm.desktop
      # Install metainfo
      install -D build/flatpak/moe.nomm.Nomm.metainfo.xml $out/share/metainfo/moe.nomm.Nomm.metainfo.xml
      # Install logo
      install -D assets/icons/nomm-logo.svg $out/share/icons/hicolor/scalable/apps/moe.nomm.Nomm.svg
      # Other files (shenanigans)
      install -d $out/share/nomm
      cp src/nomm/*.yaml $out/${python3Packages.python.sitePackages}/..
      cp release_bites.yaml $out/${python3Packages.python.sitePackages}/..
      # Copy assets
      cp -r assets $out/share/nomm/assets
      # Localisation
      find locale -name "*.po" | while read -r po; do
        language_code=$(basename "$po" .po)
        install -d "$out/share/locale/$language_code/LC_MESSAGES"
        msgfmt "$po" -o "$out/share/locale/$language_code/LC_MESSAGES/moe.nomm.Nomm.mo"
      done
    ''
    # Fix broken images
    + ''
      export GDK_PIXBUF_MODULE_FILE="${
        gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
          extraLoaders = [
            webp-pixbuf-loader
          ];
        }
      }"
    '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        "''${gappsWrapperArgs[@]}"
        --set PATH ${
          lib.makeBinPath [
            glib.dev # glib-compile-resources
            p7zip # 7z
          ]
        }
    )
  '';

  # has no tests
  doCheck = false;

  pythonImportsCheck = [ "nomm" ];

  __structuredAttrs = true;

  meta = {
    description = "Native Open Mod Manager";
    homepage = "https://nomm.moe";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "nomm";
    platforms = lib.platforms.linux;
  };
})
