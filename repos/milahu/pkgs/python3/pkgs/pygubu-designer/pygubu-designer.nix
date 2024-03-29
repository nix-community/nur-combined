{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pygubu-designer";
  version = "0.38";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "alejandroautalan";
    repo = "pygubu-designer";
    rev = "v${version}";
    hash = "sha256-400N2Pld5nzu5zO9FrQ8GKYvA4U0uT8aW8H3dGPljhQ=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    appdirs
    autopep8
    mako
    pygubu
    screeninfo
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    all = [
      awesometkinter
      customtkinter
      packaging
      pillow
      tkcalendar
      tkintermapview
      tkintertable
      tkinterweb
      tksheet
      ttkwidgets
    ];
    awesometkinter = [
      awesometkinter
    ];
    customtkinter = [
      customtkinter
      packaging
      pillow
    ];
    tkcalendar = [
      tkcalendar
    ];
    tkintermapview = [
      tkintermapview
    ];
    tkintertable = [
      tkintertable
    ];
    tkinterweb = [
      tkinterweb
    ];
    tksheet = [
      tksheet
    ];
    ttkwidgets = [
      ttkwidgets
    ];
  };

  meta = with lib; {
    description = "A simple GUI designer for the python tkinter module";
    homepage = "https://github.com/alejandroautalan/pygubu-designer";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "pygubu-designer";
  };
}
