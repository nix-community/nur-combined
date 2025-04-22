{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mpv-downmix-gui";
  version = "0.0.3";
  #pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "mpv-downmix-gui";
    rev = version;
    hash = "sha256-0wBoZspBmbw1BaPWgosrV28dmeoyadXM4bce5S8VvH0=";
  };

  nativeBuildInputs = [
    #python3.pkgs.setuptools
    #python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    tkinter
  ];

  # fix: WARNING: Testing via this command is deprecated and will be removed in a future version. Users looking for a generic test entry point independent of test runner are encouraged to use tox.
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';

  meta = with lib; {
    description = "Mpv GUI to modify the parameters to downmix surround sound to stereo";
    homepage = "https://github.com/milahu/mpv-downmix-gui";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "mpv-downmix-gui";
    platforms = platforms.all;
  };
}
