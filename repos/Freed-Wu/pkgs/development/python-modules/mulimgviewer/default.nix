{ mySources
, python3
, wrapGAppsHook
  # , setuptools-generate
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
  nativeCheckInputs = [
    # setuptools-generate
    setuptools
  ];
  # wait new version release to remove the following code
  postInstall = ''
    install -Dm644 assets/desktop/mulimgviewer.desktop -t $out/share/applications
    install -Dm644 src/mulimgviewer/mulimgviewer.png -t $out/share/icons/hicolor/256x256/apps
  '';
  pythonImportsCheck = [
    "mulimgviewer"
  ];
}
