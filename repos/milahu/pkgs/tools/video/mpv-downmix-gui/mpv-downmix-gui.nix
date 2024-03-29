{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mpv-downmix-gui";
  version = "0.0.1";
  #pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "mpv-downmix-gui";
    rev = "27b9e601e6210f8907dc27aa644f57126a4aeb6c";
    hash = "sha256-bAhOjKTURK3rTkRDet7RQz9H4KFA8/PvFErqC6X3iyo=";
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
