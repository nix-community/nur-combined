python:
let
  python-personal-packages = python-packages: with python-packages; [
    pygame
    ConfigArgParse
    django
    matplotlib
    virtualenvwrapper
    pip
    pandas
    scikitlearn
    ipykernel
    Pweave
    jupyter
    tkinter
    grip
  ];
in
python.withPackages python-personal-packages
