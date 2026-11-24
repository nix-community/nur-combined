{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  adwaita-icon-theme,
  av,
  coreutils,
  ffmpeg,
  gdk-pixbuf,
  gettext,
  gobject-introspection,
  gst_all_1,
  gsettings-desktop-schemas,
  gtk4,
  hicolor-icon-theme,
  libadwaita,
  mmengine,
  numpy,
  opencv4,
  pillow,
  pycairo,
  pygobject3,
  requests,
  termcolor,
  torch,
  torchvision,
  tqdm,
  ultralytics,
  ultralytics-thop,
  wcwidth,
  wrapGAppsHook3,
}:

let
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "ladaapp";
    repo = "lada";
    tag = "v${version}";
    hash = "sha256-9ZIGg7OhAOvt/6iyaVlpqMmiRjooVBe9KP7ly2wX8FQ=";
  };

  # Keep torch, torchvision and ultralytics on the same torch variant.
  # Ultralytics has its own torch/torchvision inputs,
  # overriding only lada's dependencies would otherwise pull a second.
  ultralytics-thop' = ultralytics-thop.override { inherit torch; };
  ultralytics' =
    (ultralytics.override {
      inherit torch torchvision;
      ultralytics-thop = ultralytics-thop';
    }).overridePythonAttrs
      (old: {
        # Lada's inference code uses Ultralytics internals,
        # and upstream ships this patch to keep NMS from timing out on long videos.
        # It applies cleanly to the 8.4.x series, including nixpkgs' current 8.4.51.
        patches = (old.patches or [ ]) ++ [ "${src}/patches/increase_mms_time_limit.patch" ];
      });
in
buildPythonPackage (finalAttrs: {
  pname = "lada";
  inherit version src;

  # PyAV 19 removed the metadata_errors keyword used by upstream 0.11.0.
  patches = [ ./0001-pyav-19-compat.patch ];

  pyproject = true;

  build-system = [ setuptools ];

  nativeBuildInputs = [
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    gsettings-desktop-schemas
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk4
    hicolor-icon-theme
    libadwaita
  ];

  dependencies = [
    av
    mmengine
    numpy
    opencv4
    pillow
    pycairo
    pygobject3
    requests
    termcolor
    torch
    torchvision
    tqdm
    ultralytics'
    wcwidth
  ];

  # The upstream pins are deliberate (Ultralytics internals and OpenCV HighGUI behavior),
  # but nixpkgs carries slightly newer compatible releases.
  pythonRelaxDeps = [
    "ultralytics"
    "opencv-python"
  ];

  preBuild = ''
    sh translations/compile_po.sh --release
  '';

  postInstall = ''
    mkdir -p $out/share/lada/locale
    cp -r lada/locale/. $out/share/lada/locale/

    install -Dm644 packaging/flatpak/main/io.github.ladaapp.lada.desktop \
      $out/share/applications/io.github.ladaapp.lada.desktop
    install -Dm644 packaging/flatpak/main/io.github.ladaapp.lada.metainfo.xml \
      $out/share/metainfo/io.github.ladaapp.lada.metainfo.xml
    install -Dm644 assets/io.github.ladaapp.lada.png \
      $out/share/icons/hicolor/128x128/apps/io.github.ladaapp.lada.png
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          coreutils
        ]
      }
      --set-default LOCALE_DIR "$out/share/lada/locale"
      --set-default YOLO_OFFLINE True
    )
  '';

  pythonImportsCheck = [
    "lada"
    "lada.cli.main"
    "lada.gui.main"
  ];

  doCheck = false;

  meta = {
    description = "Restore videos with pixelated/mosaic regions";
    homepage = "https://codeberg.org/ladaapp/lada";
    changelog = "https://codeberg.org/ladaapp/lada/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ knightfemale ];
    mainProgram = "lada";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
