{
  stdenv,
  config,
  lib,
  fetchFromGitHub,
  fetchurl,
  bzip2,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  makeDesktopItem,
  makeWrapper,
  fmt,
  gettext,
  gtk3,
  inih,
  libevdev,
  pam,
  python3,
  dlib,

  cudaSupport ? config.cudaSupport,
}:

let
  data =
    let
      baseurl = "https://github.com/davisking/dlib-models/raw/41b158a24d569c8f12151a407fd1cee99fcf3d8b";
    in
    {
      "dlib_face_recognition_resnet_model_v1.dat" = fetchurl {
        url = "${baseurl}/dlib_face_recognition_resnet_model_v1.dat.bz2";
        sha256 = "0fjm265l1fz5zdzx5n5yphl0v0vfajyw50ffamc4cd74848gdcdb";
      };
      "mmod_human_face_detector.dat" = fetchurl {
        url = "${baseurl}/mmod_human_face_detector.dat.bz2";
        sha256 = "117wv582nsn585am2n9mg5q830qnn8skjr1yxgaiihcjy109x7nv";
      };
      "shape_predictor_5_face_landmarks.dat" = fetchurl {
        url = "${baseurl}/shape_predictor_5_face_landmarks.dat.bz2";
        sha256 = "0wm4bbwnja7ik7r28pv00qrl3i1h6811zkgnjfvzv7jwpyz7ny3f";
      };
    };

  # wrap howdy and howdy-gtk
  py = python3.withPackages (p: [
    p.numpy
    p.elevate
    (p.face-recognition.override {
      inherit cudaSupport;
      dlib = python3.pkgs.dlib.override { dlib = dlib.override { inherit cudaSupport; }; };
    })
    p.keyboard
    (p.opencv4.override {
      enableGtk3 = true;
      enableCuda = cudaSupport;
      enableCudnn = true;
    })
    p.pycairo
    p.pygobject3
    p.pygobject-stubs
  ]);

  desktopItem = makeDesktopItem {
    name = "howdy";
    exec = "howdy-gtk";
    icon = "howdy";
    comment = "Howdy facial authentication";
    desktopName = "Howdy";
    genericName = "Facial authentication";
    categories = [
      "System"
      "Security"
    ];
  };
in
stdenv.mkDerivation {
  pname = "howdy";
  version = "2.6.1-unstable-2025-02-02";

  src = fetchFromGitHub {
    owner = "boltgolt";
    repo = "howdy";
    rev = "c4521c14ab8c672cadbc826a3dbec9ef95b7adb1";
    hash = "sha256-y/BVj6DdnppIegAEm2FtrOdiqF23Q+U6v2EZ4A9H7iU=";
  };

  patches = [
    # Don't install the config file. We handle it in the module.
    ./dont-install-config.patch

    ./0001-refactor-format.patch
    ./0002-feat-compare-add-initialization-watchdog-to-prevent-.patch
  ];

  mesonFlags = [
    "-Dconfig_dir=/etc/howdy"
    "-Duser_models_dir=/var/lib/howdy/models"
    # wrap howdy and howdy-gtk
    "-Dpython_path=${lib.getExe py}"
  ];

  postPatch = ''
    substituteInPlace howdy/src/cli/config.py \
      --replace-fail '/bin/nano' 'nvim'
  '';

  nativeBuildInputs = [
    bzip2
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    fmt
    gettext
    gtk3
    inih
    libevdev
    pam
    py
  ];

  postInstall =
    let
      inherit (lib) mapAttrsToList concatStrings;
    in
    ''
      # install dlib data
      rm -rf $out/share/dlib-data/*
      ${concatStrings (
        mapAttrsToList (n: v: ''
          bzip2 -dc ${v} > $out/share/dlib-data/${n}
        '') data
      )}

      # install desktop item & image
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/{48x48,128x128,256x256}/apps
      cp "${desktopItem}"/share/applications/* "$out/share/applications/"
      ln -s "$out/share/howdy-gtk/logo.png" $out/share/icons/hicolor/48x48/apps/howdy.png
      ln -s "$out/share/howdy-gtk/logo.png" $out/share/icons/hicolor/128x128/apps/howdy.png
      ln -s "$out/share/howdy-gtk/logo.png" $out/share/icons/hicolor/256x256/apps/howdy.png

      echo '${lib.getExe py} "${placeholder "out"}/lib/howdy-gtk/init.py" "$@"' > $out/bin/howdy-gtk
    '';

  # dontWrapGApps = true;
  # dontInstallCheck = true;

  # preFixup = ''
  #
  #   wrapProgramShell $out/bin/howdy \
  #     "''${gappsWrapperArgs[@]}" \
  #     --prefix PATH : ${lib.makeBinPath [ py ]}
  #
  #   wrapProgramShell $out/bin/howdy-gtk \
  #     "''${gappsWrapperArgs[@]}" \
  #     --prefix PATH : ${lib.makeBinPath [ py ]}
  # '';

  meta = {
    description = "Windows Hello™ style facial authentication for Linux";
    homepage = "https://github.com/boltgolt/howdy";
    license = lib.licenses.mit;
    mainProgram = "howdy";
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ fufexan ];
  };
}
