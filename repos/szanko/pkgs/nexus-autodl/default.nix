{ lib, pkgs, fetchFromGitHub, makeWrapper }:

let
  py = pkgs.python311Packages;  
  pyPath = py.makePythonPath (
    (with py; [ click pillow pyautogui tkinter ])
    ++ [ py."opencv-python" ]  
  );
  binPath = lib.makeBinPath (with pkgs; [ scrot xdotool ]);
in
  py.buildPythonApplication rec {
    pname = "nexus-autodl";
    version = "unstable-2025-07-12";
    src = fetchFromGitHub {
      owner = "parsiad";
      repo  = "nexus-autodl";
      rev   = "134173980675e715fbeabed2f721c186f3fd08a5";
      hash  = "sha256-KCbFl2kmFcShbg7zBX26lm8ueV2LOvTMXu92W2/yg58=";
    };

    format = "other";
    dontBuild = true;

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [
      pkgs.scrot
      pkgs.xdotool
    ];

    propagatedBuildInputs =
      (with py; [ click pillow pyautogui tkinter ])
      ++ [ py."opencv-python" ];

    pythonImportsCheck = [ ];

    installPhase = ''
      install -Dm0644 nexus_autodl.py "$out/libexec/${pname}/nexus_autodl.py"
      makeWrapper ${py.python.interpreter} "$out/bin/nexus-autodl" \
      --set PYTHONPATH "${pyPath}" \
      --prefix PATH : "${binPath}" \
      --add-flags "$out/libexec/${pname}/nexus_autodl.py"
    '';

    meta = with lib; {
      description = "Nexus AutoDL autoclicker for Nexus Mods";
      homepage    = "https://github.com/parsiad/nexus-autodl";
      license     = licenses.mit;
      maintainers = with maintainers; [ szanko ];
      mainProgram = "nexus-autodl";
      platforms   = platforms.linux;
      broken = true;
    };
  }

