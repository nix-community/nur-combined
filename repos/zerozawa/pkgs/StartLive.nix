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
}: let
  pyqtdarktheme-fork = python3Packages.buildPythonPackage {
    pname = "pyqtdarktheme-fork";
    version = "2.3.4-unstable-2024-05-16";

    src = fetchFromGitHub {
      owner = "Radekyspec";
      repo = "PyQtDarkTheme";
      rev = "c72da81aa0d26e49f2fc6406fc5c6a57150238f6";
      hash = "sha256-3xomKhgP9a2jbPk/EDfI+3xFp10ugKCFCuAnSL45U0c=";
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
    version = "0.8.7";

    src = fetchFromGitHub {
      owner = "Radekyspec";
      repo = pname;
      rev = version;
      hash = "sha256-UUumeUsTjb1a3r1yUi/XOJ0NMoH4F5dx+jkgIUGTB7o=";
    };

    format = "other";

    nativeBuildInputs = [
      copyDesktopItems
      makeWrapper
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
        finalAttrs:
          with finalAttrs; {
            dependencies = dependencies ++ (with optional-dependencies; socks);
          }
      ))
      obsws-python
      keyring
      darkdetect
      semver
      pyqtdarktheme-fork
    ];

    dontBuild = true;
    dontConfigure = true;
    dontWrapQtApps = true;

    # 修复上游 bug: keyring 可能返回空字符串导致 JSON 解析失败
    postPatch = ''
      substituteInPlace app_state/__init__.py \
        --replace-fail ') is not None:' ') is not None and app:'
    '';

    installPhase = ''
      runHook preInstall

      # 创建应用目录
      mkdir -p $out/share/startlive

      # 复制所有 Python 源代码和资源文件
      cp -r ./* $out/share/startlive/

      # 创建启动脚本
      mkdir -p $out/bin
      cat > $out/bin/startlive <<EOF
      #!${python3Packages.python.interpreter}
      import sys
      import os

      # 设置安装目录
      install_dir = "$out/share/startlive"
      sys.path.insert(0, install_dir)
      os.chdir(install_dir)

      # 设置 __file__ 为实际的 StartLive.py 路径,以便应用能正确定位资源
      __file__ = os.path.join(install_dir, "StartLive.py")

      # 启动主程序
      exec(compile(open(__file__).read(), __file__, 'exec'))
      EOF
      chmod +x $out/bin/startlive

      # Wrap with Qt environment for PySide6 platform plugins
      wrapProgram $out/bin/startlive \
        --set QT_PLUGIN_PATH "${qt6.qtbase}/lib/qt-6/plugins" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      # 安装图标
      mkdir -p $out/share/pixmaps
      ln -s $out/share/startlive/docs/images/icon_left.png $out/share/pixmaps/startlive.png

      # 安装文档
      mkdir -p $out/share/doc/startlive
      ln -s $out/share/startlive/docs $out/share/doc/startlive/docs

      # 安装许可证
      ln -s $out/share/startlive/LICENSE $out/share/doc/startlive/LICENSE

      runHook postInstall
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
      description = "绕过B站直播姬获取推流地址 - Bypass Bilibili LiveHime to get streaming address";
      longDescription = ''
        StartLive is a tool to bypass the requirement to use Bilibili's official
        "LiveHime" client to start streaming. It provides a simple GUI to obtain
        RTMP streaming addresses for Bilibili live streaming.
      '';
      homepage = "https://github.com/Radekyspec/StartLive";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      mainProgram = "startlive";
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
