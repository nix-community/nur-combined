{ name
  , lib
  , python3
  , fetchFromGitHub
  , makeDesktopItem
  , writeShellScript
  , ...
  }:
  let
    wrapper = writeShellScript "eontimer-wrapper" ''
      export QT_QPA_PLATFORM=xcb
      exec @out@/bin/EonTimer
    '';
  in
  python3.pkgs.buildPythonApplication rec {
    pname = "eontimer";
    version = "3.0.0-rc.6";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "DasAmpharos";
      repo = "EonTimer";
      rev = version;
      hash = "sha256-+XN/VGGlEg2gVncRZrWDOZ2bfxt8xyIu22F2wHlG6YI=";
    };

    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
    ];

    dependencies = with python3.pkgs; [
      altgraph
      certifi
      charset-normalizer
      idna
      libsass
      macholib
      packaging
      pillow
      pipdeptree
      platformdirs
      pyinstaller
      pyinstaller-hooks-contrib
      pyside6
      requests
      setuptools
      shiboken6
      urllib3
    ];

    nativeBuildInputs = [
      python3.pkgs.pyinstaller
    ];

    buildPhase = ''
      runHook preBuild

      pyinstaller --clean --noconfirm EonTimer.spec

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/applications
      cp dist/EonTimer $out/bin/
      install -Dm755 -T ${wrapper} $out/bin/eontimer
      substituteInPlace $out/bin/eontimer --subst-var out

      runHook postInstall
    '';

    postInstall = ''
      install -Dm755 -t $out/share/applications ${
           makeDesktopItem {
             name = "eontimer";
             desktopName = "EonTimer";
             comment = "Start EonTimer";
             exec = "eontimer";
           }
         }/share/applications/eontimer.desktop
    '';



    meta = with lib; {
      description = "Pokémon RNG Timer";
      homepage = "https://github.com/DasAmpharos/EonTimer";
      changelog = "https://github.com/DasAmpharos/EonTimer/releases/tag/${version}";
      license = licenses.mit;
      mainProgram = "eon-timer";
    };
  }
