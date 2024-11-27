{
  mySources,
  python3,
  wrapGAppsHook,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.mulimgviewer) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    # https://github.com/NixOS/nixpkgs/issues/181500
    wrapGAppsHook
    piexif
    pillow
    wxPython_4_2
    requests
  ];
  nativeBuildInputs = [
    setuptools-scm
  ];
  patchPhase = ''
    sed -i 's/, "setuptools-generate"//' pyproject.toml
    sed -i 's/wx.MenuItem( \(self.m_menu[0-9]\+\),/\1.Append( /g' src/mulimgviewer/gui/*.py
  '';
  # wait new version release to remove the following code
  postInstall = ''
    install -Dm644 assets/desktop/mulimgviewer.desktop -t $out/share/applications
    install -Dm644 src/mulimgviewer/mulimgviewer.png -t $out/share/icons/hicolor/256x256/apps
  '';
  pythonImportsCheck = [
    "mulimgviewer"
  ];

  meta = with lib; {
    # error: wxpython-4.2.1 not supported for interpreter python3.12
    broken = true;
    homepage = "https://mulimgviewer.readthedocs.io";
    description = "MulimgViewer is a multi-image viewer that can open multiple images in one interface, which is convenient for image comparison and image stitching";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
