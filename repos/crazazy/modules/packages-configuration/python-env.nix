python:
let
  python-personal-packages = python-packages: with python-packages; [
        pygame
        ConfigArgParse
        django_2_2
        matplotlib
        virtualenvwrapper
        pandas
        ipykernel
        jupyter
        tkinter
      ];
in python.withPackages python-personal-packages
