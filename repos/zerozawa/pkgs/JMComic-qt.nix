{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  qt6,
  vulkan-loader,
  sr-vulkan,
  addDriverRunpath,
  ...
}:
let
  commonx = python3Packages.buildPythonPackage rec {
    pname = "commonx";
    version = "0.6.39";
    format = "setuptools";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Lo/kHgeMkhUvlZO1qOeUoLdINU4rhz7mFjAGnXRad9U=";
    };
    doCheck = false;
  };

  jmcomic = python3Packages.buildPythonPackage rec {
    pname = "jmcomic";
    version = "2.6.9";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Pfrtc6IQ3Ha7jZ1edwHgeTblEgBiSRrSeqShqskPcNc=";
    };
    build-system = with python3Packages; [ setuptools ];
    dependencies = with python3Packages; [
      curl-cffi pillow pycryptodome pyyaml commonx
    ];
    doCheck = false;
    pythonImportsCheck = [ "jmcomic" ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "JMComic-qt";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "tonquer";
    repo = "JMComic-qt";
    rev = "v${version}";
    hash = "sha256-ZeyJcCc2OdCeimOudDUaw1d/Bs5Q+5kE15W89G5SHGU=";
  };

  format = "other";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    addDriverRunpath
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    vulkan-loader
  ];

  propagatedBuildInputs = with python3Packages; [
    pyside6 pillow lxml pycryptodomex pysocks natsort curl-cffi
    webdavclient3 tqdm pysmb beautifulsoup4 setuptools
    (httpx.overridePythonAttrs (finalAttrs: {
      dependencies = finalAttrs.dependencies ++ (with finalAttrs.optional-dependencies; http2 ++ socks);
    }))
    jmcomic
    sr-vulkan  # This now includes models
  ];

  dontBuild = true;
  dontConfigure = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jmcomic-qt
    cp -r src/* $out/share/jmcomic-qt/
    cp -r lib $out/share/jmcomic-qt/

    # Link sr_vulkan from its site-packages
    for site_packages in ${sr-vulkan}/lib/python*/site-packages; do
      if [ -d "$site_packages/sr_vulkan" ]; then
        ln -s "$site_packages/sr_vulkan" $out/share/jmcomic-qt/
        # Also link model packages that are now in sr-vulkan's site-packages
        for model_path in $site_packages/sr_vulkan_model_*; do
          if [ -d "$model_path" ]; then
            ln -s "$model_path" $out/share/jmcomic-qt/
          fi
        done
        break
      fi
    done

    mkdir -p $out/bin

    cat > $out/bin/JMComic-qt << EOF
    #!${python3Packages.python.interpreter}
    import sys
    import os

    install_dir = "$out/share/jmcomic-qt"
    sys.path.insert(0, install_dir)
    os.chdir(install_dir)

    os.environ["LD_LIBRARY_PATH"] = os.path.join(install_dir, "lib", "linux") + ":" + os.environ.get("LD_LIBRARY_PATH", "")

    exec(compile(open(os.path.join(install_dir, "start.py")).read(), "start.py", "exec"))
    EOF

    chmod +x $out/bin/JMComic-qt

    wrapProgram $out/bin/JMComic-qt \
      --set QT_PLUGIN_PATH "${qt6.qtbase}/lib/qt-6/plugins" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix LD_LIBRARY_PATH : "${vulkan-loader}/lib"

    mkdir -p $out/share/pixmaps
    cp $src/res/icon/logo_round.png $out/share/pixmaps/JMComic.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "JMComic-qt";
      desktopName = "JMComic";
      comment = "禁漫天堂，18comic，使用qt实现的PC客户端";
      exec = "JMComic-qt %u";
      icon = "JMComic";
      terminal = false;
      type = "Application";
      categories = [ "Graphics" "Network" ];
    })
  ];

  doCheck = false;

  meta = with lib; {
    description = "禁漫天堂，18comic，使用qt实现的PC客户端，支持Windows，Linux，MacOS";
    homepage = "https://github.com/tonquer/JMComic-qt";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    mainProgram = "JMComic-qt";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
