{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, wheel
, python3
, tesseract
, xdotool
, xwd
, imagemagick
, x11vnc
, pillow
#, autopy
, pytesseract
, tesserocr
#, opencv-contrib-python
, torch
, torchvision
, vncdotool
, pyautogui
, pyscreeze
, serpent
, pyro4
}:

buildPythonPackage rec {
  pname = "guibot";
  version = "0.51";

  src = fetchFromGitHub {
    owner = "intra2net";
    repo = "guibot";
    rev = "v${version}";
    hash = "sha256-3ocRuRhrDI8So5bd7Ju6rNthMtMWfYoZuekojGMWLe8=";
  };

  postPatch = ''
    mv packaging/setup.py setup.py
    substituteInPlace setup.py \
      --replace-warn "../" ""

    substituteInPlace guibot/controller.py \
      --replace-warn \
        'subprocess.Popen(("xwd"' \
        'subprocess.Popen(("${xwd}/bin/xwd"' \
      --replace-warn \
        'subprocess.call(("convert"' \
        'subprocess.call(("${imagemagick}/bin/convert"' \
      --replace-warn \
        'self.params[category]["binary"] = "xdotool"' \
        'self.params[category]["binary"] = "${xdotool}/bin/xdotool"'

    substituteInPlace docs/examples/*.py \
      --replace-warn '#!/usr/bin/python3' '#!/usr/bin/env python3' \
      --replace-warn $'# Only needed if not installed system wide\n' "" \
      --replace-warn $'import sys\n' "" \
      --replace-warn "sys.path.insert(0, '../..')"$'\n' "" \
      --replace-warn $'\n\n# Program start here\n#\n' ""
  '';

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [

    # text matching
    tesseract

    # screen controlling
    xdotool
    xwd
    imagemagick
    # TODO: PyAutoGUI's scrot dependencies are broken on CentOS/Rocky, currently provided offline
    #scrot
    x11vnc

    # dependencies that could be installed using pip
    # guibot/packaging/pip_requirements.txt"

    # minimal
    pillow

    # backends
    # https://github.com/autopilot-rs/autopy/
    # A simple, cross-platform GUI automation module for Python and Rust.
    #autopy

    # OCR is currently not tested on Windows due to custom Tesseract OCR installers
    pytesseract
    tesserocr
    #opencv-contrib-python
    torch
    torchvision
    vncdotool
    pyautogui
    # NOTE: These decared version of Pillow has issues with the latest Pyscreeze 0.1.30 thus there is a restrain on Pyscreeze installation
    pyscreeze

    # error: pyro4-4.82 not supported for interpreter python3.11
    # optional proxy guibot interface deps
    #serpent
    #pyro4

    # coverage analysis to use for testing
    #coverage
    #codecov

    # linters and auto-reviews
    #pycodestyle
    #pydocstyle

    # GUI to use for testing
    # TODO: the most recent version at the time works on windows but not on linux
    #pyqt5

  ];

  postInstall = ''
    mkdir -p $out/share/docs/guibot
    cp -r docs/examples $out/share/docs/guibot
  '';

  # tests require pyqt5
  doCheck = false;

  pythonImportsCheck = [ "guibot" ];

  meta = with lib; {
    description = "GUI automation using a variety of computer vision and display control backends";
    homepage = "https://github.com/intra2net/guibot";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
