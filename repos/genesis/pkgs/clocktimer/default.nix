{ stdenv, fetchFromGitLab, gst_all_1, python3Packages, makeDesktopItem, qt5 }:

python3Packages.buildPythonApplication rec {
  pname = "clocktimer";
  version = "0.9";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "lastrodamo";
    repo = pname;
    #rev = "v${version}";
    rev = "4b94441e69db532efc96b46800d746c2b8603e72";
    sha256 = "02r2xiwz8gid2gp82c21xnq7ys6js8jqpr7yvjxbx9gzgvbvgb04";
  };

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  propagatedBuildInputs = with python3Packages; [ pyqt5_with_qtmultimedia ];
  buildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  dontBuild = true;

  desktopItem = makeDesktopItem {
    name = "Clocktimer";
    exec = "@out@/bin/clocktimer";
    #icon = "Clocktimer";
    desktopName = "Clocktimer";
    genericName = "clock";
    categories = "Application;";
    startupNotify = "false";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -R ./ $out
    ln -s $out/clocktimer.py $out/bin/clocktimer
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
    qtWrapperArgs+=(--prefix QT_PLUGIN_PATH : "${qt5.qtmultimedia}/lib/")
    wrapQtApp $out/bin/clocktimer
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A countdown timer made with Python 3 and PyQt5 with custom presets";
    homepage = https://gitlab.com/lastrodamo/clocktimer;
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
  };
}
