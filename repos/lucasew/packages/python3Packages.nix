{ lib, python3Packages, pkgs, ... }:
let
  inherit (pkgs) fetchzip;
  inherit (python3Packages) fetchPypi buildPythonApplication;
in
rec {
  autoit = buildPythonApplication rec {
    pname = "autoit";
    version = "0.2.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-9j+62/F4hWUUSgTmiYoDlZIgadthMxsZeuSRaJlw1xs=";
    };
    doCheck = false; # test crashes because there is no display
    propagatedBuildInputs = with pkgs; [
      python3Packages.xlib
      xdotool
    ];
  };
  pyautogui = buildPythonApplication rec {
    pname = "PyAutoGUI";
    version = "0.9.52";
    doCheck = false;
    propagatedBuildInputs = [
      mouseinfo
      pygetwindow
      pymsgbox
      python3Packages.xlib
      python3Packages.tkinter
      pyperclip
      pyscreeze
      pytweening
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-pIbLa4GLy835i0jQEMfO6WQTT6OUt1bozm5Q1DtY7Mg=";
    };
  };
  pygetwindow = buildPythonApplication rec {
    pname = "PyGetWindow";
    format = "pyproject";
    version = "0.0.9";
    doCheck = false;
    propagatedBuildInputs = [
      pyrect
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-F4lDVefSswXNgy1xdwg4QBfBaYqQziT29/vwJC3Qpog=";
    };
  };
  pyrect = buildPythonApplication rec {
    pname = "PyRect";
    version = "0.1.4";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Oy+nNTzjKhGqawoVSVlo0qdjQjyJR64ki5LAN9704gI=";
    };
  };
  pyscreeze = buildPythonApplication rec {
    pname = "PyScreeze";
    version = "0.1.26";
    doCheck = false;
    propagatedBuildInputs = [
      python3Packages.pillow
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-IkljEUF2II7uE7C5hN4fX9wRtzk85IrStSOQ3IhV00Y=";
    };
  };
  mouseinfo = buildPythonApplication rec {
    pname = "MouseInfo";
    version = "0.1.3";
    doCheck = false;
    propagatedBuildInputs = [
      pyperclip
      python3_xlib
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-LGL7iIUGK45SCjzOCil8ZXrcwIxglS6wW8glbvb39uc=";
    };
  };
  pyperclip = buildPythonApplication rec {
    pname = "pyperclip";
    version = "1.8.2";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-EFJUqLBJNPC8hOnCTrNgpZGq9lNcne9fKdkq8Qepv1c=";
    };
  };
  python3_xlib = buildPythonApplication rec {
    pname = "python3-xlib";
    version = "0.15";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-3EJF865KpZScHREu5HI5Aa3jepZyG6lkXyv6VuWzg/g=";
    };
  };
  pymsgbox = buildPythonApplication rec {
    pname = "PyMsgBox";
    version = "1.0.9";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-IZQifei/96PW2lQYSHBaFV3LsqBu4SDZ8oCh1/USY/8=";
    };
  };
  pytweening = buildPythonApplication rec {
    pname = "PyTweening";
    version = "1.0.3";
    doCheck = false;
    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/b9/f8/c32a58d6e4dff8aa5c27e907194d69f3b57e525c2e4af96f39c6e9c854d2/PyTweening-1.0.3.zip";
      sha256 = "sha256-MCjLQQ3E1KYKJffXlsCYlccezgrBPgbLXuIj3lOhPA0=";
    };
  };
}

