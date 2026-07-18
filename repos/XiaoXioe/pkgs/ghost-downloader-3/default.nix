{
  lib,
  python3,
  fetchFromGitHub,
  fetchurl,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  makeWrapper,
  qt6,
}:

let
  # Local wreq python package using precompiled ABI3 wheels
  wreq = python3.pkgs.buildPythonPackage rec {
    pname = "wreq";
    version = "0.12.0";
    format = "wheel";

    src =
      let
        system = stdenv.hostPlatform.system;
      in
      if system == "x86_64-linux" then
        fetchurl {
          url = "https://files.pythonhosted.org/packages/c2/b1/aacc3eb58e8ceee9f86cc097a6a077909b5989ccb95aa3ac877cbdbf7a43/wreq-0.12.0-cp311-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
          sha256 = "67fc6b7fd146e1c3b8e1b9c571fd03535509ec3bf9d1f983abd064a53250c7b9";
        }
      else if system == "aarch64-linux" then
        fetchurl {
          url = "https://files.pythonhosted.org/packages/18/88/901c400f55ab269861430667b47d77a8096f03d88ae248d54e25060805c1/wreq-0.12.0-cp311-abi3-manylinux_2_34_aarch64.whl";
          sha256 = "35bc7899a3f574d4c6c1474eb14cb08b267ba14e7bc3dab69283ca54f6818b61";
        }
      else
        throw "Unsupported system for wreq: ${system}";

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [ stdenv.cc.cc.lib ];

    pythonImportsCheck = [ "wreq" ];

    meta = {
      description = "Ergonomic Python HTTP client with TLS fingerprint emulation";
      homepage = "https://github.com/0x676e67/wreq-python";
      license = lib.licenses.mit;
    };
  };

  # Local pysidesix-frameless-window package
  pysidesix-frameless-window = python3.pkgs.buildPythonPackage rec {
    pname = "pysidesix-frameless-window";
    version = "0.8.1";
    format = "setuptools";

    src = fetchPypi {
      pname = "pysidesix_frameless_window";
      inherit version;
      sha256 = "95eefa64abdaca9d730bc097fd39e2cd07d3443a47a1645cc936a0076996d7cd";
    };

    propagatedBuildInputs = with python3.pkgs; [
      pyside6
    ];

    doCheck = false;

    pythonImportsCheck = [ "qframelesswindow" ];

    meta = {
      description = "A cross-platform frameless window based on PySide6";
      homepage = "https://github.com/zhiyiYo/PyQt-Frameless-Window/tree/PySide6";
      license = lib.licenses.lgpl3Only;
    };
  };

  # Local pyside6-fluent-widgets package
  pyside6-fluent-widgets = python3.pkgs.buildPythonPackage rec {
    pname = "pyside6-fluent-widgets";
    version = "1.11.2";
    format = "setuptools";

    src = fetchPypi {
      pname = "pyside6_fluent_widgets";
      inherit version;
      sha256 = "cf49ff76b9b2ad1dc24f071a1b2a3f5f0a67d7adf655915071ddfb7342caf175";
    };

    propagatedBuildInputs = with python3.pkgs; [
      pyside6
      pysidesix-frameless-window
      darkdetect
    ];

    doCheck = false;

    pythonImportsCheck = [ "qfluentwidgets" ];

    meta = {
      description = "Fluent design widgets library for PySide6";
      homepage = "https://github.com/zhiyiYo/PyQt-Fluent-Widgets";
      license = lib.licenses.gpl3Only;
    };
  };

  bidict = python3.pkgs.buildPythonPackage rec {
    pname = "bidict";
    version = "0.23.1";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      sha256 = "03069d763bc387bbd20e7d49914e75fc4132a41937fa3405417e1a5a2d006d71";
    };

    nativeBuildInputs = with python3.pkgs; [ setuptools ];

    propagatedBuildInputs = with python3.pkgs; [
      typing-extensions
    ];

    doCheck = false;
  };

  desktop-notifier = python3.pkgs.buildPythonPackage rec {
    pname = "desktop-notifier";
    version = "6.2.0";
    format = "pyproject";

    src = fetchPypi {
      pname = "desktop_notifier";
      inherit version;
      sha256 = "528167b691ce40031fa92f67c9f452b7be29846613e19d11ec0c49cb5242d338";
    };

    nativeBuildInputs = with python3.pkgs; [ setuptools ];

    propagatedBuildInputs = with python3.pkgs; [
      dbus-fast
      packaging
      typing-extensions
      bidict
    ];

    doCheck = false;

    pythonImportsCheck = [ "desktop_notifier" ];

    meta = {
      description = "Python library for desktop notifications";
      homepage = "https://github.com/samschott/desktop-notifier";
      license = lib.licenses.mit;
    };
  };

  darkdetect = python3.pkgs.buildPythonPackage rec {
    pname = "darkdetect";
    version = "0.8.0";
    format = "pyproject";

    nativeBuildInputs = with python3.pkgs; [ setuptools ];

    src = fetchPypi {
      inherit pname version;
      sha256 = "b5428e1170263eb5dea44c25dc3895edd75e6f52300986353cd63533fe7df8b1";
    };

    doCheck = false;

    pythonImportsCheck = [ "darkdetect" ];

    meta = {
      description = "Detect OS Dark Mode from Python";
      homepage = "https://github.com/albertosottile/darkdetect";
      license = lib.licenses.bsd3;
    };
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "ghost-downloader-3";
  version = "4.1.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "XiaoYouChR";
    repo = "Ghost-Downloader-3";
    rev = "v${version}";
    hash = "sha256-rg5ObBvhcDFguIqZZwUurKSr2/4AFzGRL7Xe98vE5Ys=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  postPatch = ''
    substituteInPlace app/config/paths.py \
      --replace-fail 'Path(".")' 'Path(__file__).resolve().parent.parent.parent'
  '';

  buildInputs = [ qt6.qtbase qt6.qtsvg ];

  propagatedBuildInputs =
    (with python3.pkgs; [
      aioftp
      libtorrent-rasterbar
      loguru
      m3u8
      mpegdash
      pyside6
      qrcode
      uvloop
    ])
    ++ [
      desktop-notifier
      darkdetect
      wreq
      pyside6-fluent-widgets
    ];

  dontBuild = true;

  installPhase = ''
      runHook preInstall

      # Create directories
      mkdir -p $out/libexec/ghost-downloader-3
      mkdir -p $out/bin
      mkdir -p $out/share/applications

      # Copy files
      cp -r . $out/libexec/ghost-downloader-3/

      # Install application icon
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp app/assets/logo.png $out/share/icons/hicolor/512x512/apps/ghost-downloader-3.png

      # Generate desktop launcher file
      cat > $out/share/applications/ghost-downloader-3.desktop <<EOF
    [Desktop Entry]
    Name=Ghost Downloader 3
    Comment=AI-boost multi-protocol concurrent downloader
    Exec=ghost-downloader-3
    Icon=ghost-downloader-3
    Terminal=false
    Type=Application
    Categories=Network;FileTransfer;
EOF

    # Create launcher script
    cat > $out/bin/ghost-downloader-3 <<EOF
#!${python3.interpreter}
import os
os.environ["QT_PLUGIN_PATH"] = "${qt6.qtsvg}/lib/qt-6/plugins"
import sys
sys.path.insert(0, "$out/libexec/ghost-downloader-3")
import runpy
runpy.run_path("$out/libexec/ghost-downloader-3/Ghost-Downloader-3.py", run_name="__main__")
EOF
    chmod +x $out/bin/ghost-downloader-3

    runHook postInstall
  '';

  meta = {
    description = "AI-boost cross-platform multi-protocol fluent-design concurrent downloader built with Python & Qt";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = lib.licenses.gpl3Only;
    mainProgram = "ghost-downloader-3";
  };
}
