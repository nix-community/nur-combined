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
  pname = "native-open-mod-manager";
  version = "0.10.1";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "Allexio";
    repo = "nomm";
    tag = finalAttrs.version;
    hash = "sha256-0+374FbaTkAjXf2+anZtckz/Ozz/B47UQVRCQTZCqus=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    gettext
  ];

  buildInputs = [
    libadwaita
    libnotify
  ];

  # https://github.com/Allexio/nomm/blob/main/build/aur/PKGBUILD
  dependencies = with python3Packages; [
    pygobject3
    pyyaml
    rarfile
    requests
    vdf
  ];

  postPatch = ''
    substituteInPlace src/gui/application.py \
        --replace-fail 'shutil.copy2' 'shutil.copyfile' \
        --replace-fail 'gresource_path = "resources.gresource"' \
           'gresource_path = os.path.join(os.path.join(GLib.get_user_data_dir(), "nomm"), "resources.gresource")'

    substituteInPlace src/gui/dashboard.py src/core/archive_manager.py \
        --replace-fail '/app/bin/unrar' "${lib.getExe unrar-free}"
  '';

  # https://github.com/Allexio/nomm/blob/main/build/flatpak/com.nomm.Nomm.yaml
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    echo "#!/bin/sh" > $out/bin/nomm
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/main.py \"\$@\"" >> "$out/bin/nomm"
    chmod +x "$out/bin/nomm"

    install -D build/flatpak/com.nomm.Nomm.desktop $out/share/applications/com.nomm.Nomm.desktop
    install -D build/flatpak/com.nomm.Nomm.metainfo.xml $out/share/metainfo/com.nomm.Nomm.metainfo.xml
    install -D assets/nomm.png $out/share/icons/hicolor/64x64/apps/com.nomm.Nomm.png

    mkdir -p $out/${python3Packages.python.sitePackages}
    cp -r src -T $out/${python3Packages.python.sitePackages}
    cp -r assets $out/${python3Packages.python.sitePackages}
    cp -r default_game_configs $out/${python3Packages.python.sitePackages}

    mkdir -p $out/share/locale/fr/LC_MESSAGES
    msgfmt locale/fr.po -o $out/share/locale/fr/LC_MESSAGES/com.nomm.Nomm.mo

    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          webp-pixbuf-loader
        ];
      }
    }"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --set PATH "${
          lib.makeBinPath [
            glib.dev # glib-compile-resources
            p7zip # 7z
          ]
        }"
    )
  '';

  meta = {
    description = "Native Open Mod Manager ";
    homepage = "https://nomm.moe";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "nomm";
    platforms = lib.platforms.linux;
  };
})
