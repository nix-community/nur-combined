{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  qt6,
  libxcb,
  libxcb-cursor,
  ...
}:
let
  pyqtdarktheme-fork = python3Packages.buildPythonPackage rec {
    pname = "pyqtdarktheme-fork";
    version = "2.3.6";

    src = fetchPypi {
      pname = "pyqtdarktheme_fork";
      inherit version;
      hash = "sha256-mrKHoDOkdCdnvLZpj7YCR77veWfXTrlJ96s27oZv8dc=";
    };

    format = "pyproject";

    nativeBuildInputs = with python3Packages; [
      poetry-core
    ];

    propagatedBuildInputs = with python3Packages; [
      darkdetect
    ];

    doCheck = false;
  };
  obsws-python = python3Packages.buildPythonPackage rec {
    pname = "obsws-python";
    version = "1.8.0";
    src = fetchPypi {
      pname = "obsws_python";
      inherit version;
      hash = "sha256-4IKJT4DesINoYf3DwiLklzCMj2YyjaYHW6ultFaiCXE=";
    };
    format = "pyproject";

    nativeBuildInputs = with python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with python3Packages; [
      websocket-client
    ];

    doCheck = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "StartLive";
  # 1.3.0 restructured the tree into the `startlive` package with a
  # setuptools entry point (`startlive = "StartLive:cli"`).
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Radekyspec";
    repo = pname;
    rev = version;
    hash = "sha256-ZZa/r9iNSCNudPqx6IKhdICqRPwHlbzKABXkd6pxfrg=";
  };

  format = "pyproject";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    python3Packages.setuptools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    libxcb
    libxcb-cursor
  ];

  propagatedBuildInputs = with python3Packages; [
    pyside6
    pillow
    qrcode
    (requests.overridePythonAttrs (
      finalAttrs: with finalAttrs; {
        dependencies = dependencies ++ (with optional-dependencies; socks);
      }
    ))
    brotli
    obsws-python
    keyring
    cryptography
    darkdetect
    semver
    pyqtdarktheme-fork
    protobuf
  ];

  dontWrapQtApps = true;

  # Upstream requirements pin the exact versions bundled in its release
  # artifacts (PySide6 ~=6.12, cryptography ~=49, protobuf <7); nixpkgs ships
  # newer compatible releases (PySide6 6.11, cryptography 50, protobuf 7).
  # The runtime smoke test covers the actual API surface.
  dontCheckRuntimeDeps = true;

  postInstall = ''
    wrapProgram $out/bin/startlive \
      --set QT_PLUGIN_PATH "${qt6.qtbase}/lib/qt-6/plugins" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    install -Dm644 docs/images/icon_left.png $out/share/pixmaps/startlive.png
    install -Dm644 docs/README_zh.md $out/share/doc/startlive/README_zh.md
    install -Dm644 LICENSE $out/share/doc/startlive/LICENSE
    install -Dm644 LICENSE-ARTWORK $out/share/doc/startlive/LICENSE-ARTWORK
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "startlive";
      desktopName = "StartLive";
      comment = "绕过B站直播姬获取推流地址";
      exec = "startlive %u";
      icon = "startlive";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "Video"
      ];
      keywords = [
        "直播"
        "rtmp"
        "startlive"
        "bilibili"
      ];
    })
  ];

  doCheck = false;

  meta = with lib; {
    description = "Bypass the requirement to use Bilibili’s official \"LiveHime\" client to start streaming.";
    longDescription = ''
      StartLive is a tool to bypass the requirement to use Bilibili's official
      "LiveHime" client to start streaming. It provides a simple GUI to obtain
      RTMP streaming addresses for Bilibili live streaming.
    '';
    homepage = "https://github.com/Radekyspec/StartLive";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "startlive";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
}
