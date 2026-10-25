{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  libx11,
  libxcursor,
  # GPU detection shells out to glxinfo on non-NVIDIA hardware; it only feeds
  # the log header and the benchmark share text, but is free to satisfy.
  mesa-demos,
  # pyperclip has no in-process backend: it execs one of these, and raises if
  # it finds none. The benchmark share button calls it without a try/except.
  wl-clipboard,
  xclip,
}:
let
  # Absent from nixpkgs, and run.py imports it unconditionally for the
  # drag-and-drop game picker. The wheel bundles a prebuilt tkdnd Tcl extension
  # per platform; only linux-x64 matches nixpkgs' Tcl 8.6 -- the -tcl9 variants
  # target a Tcl this tkinter never loads.
  tkinterdnd2 = python3.pkgs.buildPythonPackage rec {
    pname = "tkinterdnd2";
    version = "0.6.2";
    format = "wheel";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      format = "wheel";
      dist = "py3";
      python = "py3";
      hash = "sha256-tqiyKdJihsAiuy+9MRwuQx5Nm7q4EzvoDpyY57z5/lk=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [
      libx11
      libxcursor
    ];
    propagatedBuildInputs = [ python3.pkgs.tkinter ];

    # autoPatchelf aborts on the bundled aarch64 objects -- it cannot resolve
    # their NEEDED entries against x86_64 libraries. Never cd here: the phases
    # after installPhase still resolve ./dist against the build directory.
    postInstall = ''
      tkdnd="$out/${python3.sitePackages}/tkinterdnd2/tkdnd"
      rm -rf "$tkdnd"/linux-arm64 "$tkdnd"/linux-arm64-tcl9 \
        "$tkdnd"/linux-x64-tcl9 "$tkdnd"/osx-* "$tkdnd"/win-*
    '';

    pythonImportsCheck = [ "tkinterdnd2" ];

    meta = {
      description = "Python wrapper for the tkdnd Tk drag-and-drop extension";
      homepage = "https://github.com/Eliav2/tkinterdnd2";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };

  pythonEnv = python3.withPackages (ps: [
    ps.certifi
    ps.colorlog
    ps.gputil
    ps.packaging
    ps.pillow
    ps.psutil
    ps.pyperclip
    ps.requests
    ps.screeninfo
    ps.tkinter
    ps.ttkbootstrap
    tkinterdnd2
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "nx-optimizer";
  version = "3.3.0-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "MaxLastBreath";
    repo = "nx-optimizer";
    # master rather than the manager-3.2.0 release (2025-10-11): Eden and Citron
    # Neo prepend an entry to the resolution_setup enum, so every resolution
    # 3.2.0 writes for them lands one slot off. Fixed upstream 2026-07-17.
    rev = "bd98bb3c9ee7eb16c2dd3c51a8c6ecf168330cf3";
    hash = "sha256-S8z8rJ+Pi9Sd/e3PJGJcOxfX6Q0mYC2ifwsijPfyjkA=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  # The mod folder is copied out of the store with copytree, which replays the
  # store's read-only modes onto it. The README written straight after the copy
  # then fails, and every later Apply cannot overwrite what the previous one
  # laid down.
  patches = [ ./writable-mod-copies.patch ];

  postPatch = ''
    # Nix owns the version. Left alone, the in-app updater downloads a release
    # AppImage into the working directory and tries to exec it.
    substituteInPlace src/run.py \
      --replace-fail 'if platform.system() != "Darwin":' 'if False:'

    # Backups default to a subdirectory of the source tree, read-only in the
    # store. The wrapper's working directory is writable, so anchor them there
    # alongside TOTKOptimizer.ini and the logs.
    substituteInPlace src/modules/GameManager/FileManager.py \
      --replace-fail 'os.path.join(__LOCAL__, "backup", GameName)' 'os.path.join(os.getcwd(), "backup", GameName)'

    # This call reached PIL through ttkbootstrap, which re-exported Image until
    # 1.20.3 dropped it. The file's own `from PIL import Image` is unusable here
    # because the later `from tkinter import *` rebinds Image to tkinter's class,
    # so bind a second alias that no wildcard import shadows.
    substituteInPlace src/modules/FrontEnd/CanvasMgr.py \
      --replace-fail 'from PIL import Image, ImageTk, ImageFilter, ImageOps' 'from PIL import Image, ImageTk, ImageFilter, ImageOps, Image as PILImage' \
      --replace-fail 'ttk.Image.open(UI_path)' 'PILImage.open(UI_path)'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/nx-optimizer"
    cp -a src/. "$out/share/nx-optimizer"

    install -Dm644 src/GUI/LOGO.png "$out/share/pixmaps/nx-optimizer.png"

    # TOTKOptimizer.ini, logger.log and backup/ are all resolved relative to the
    # working directory, so pin one instead of littering wherever it was started.
    makeWrapper "${pythonEnv}/bin/python" "$out/bin/nx-optimizer" \
      --add-flags "$out/share/nx-optimizer/run.py" \
      --prefix PATH : "${
        lib.makeBinPath [
          mesa-demos
          wl-clipboard
          xclip
        ]
      }" \
      --run 'state="''${XDG_DATA_HOME:-$HOME/.local/share}/nx-optimizer"; mkdir -p "$state"; cd "$state"'

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "nx-optimizer";
      exec = "nx-optimizer";
      icon = "nx-optimizer";
      desktopName = "NX Optimizer";
      comment = "UltraCam mod installer for Switch games on emulators";
      categories = [
        "Game"
        "Utility"
      ];
    })
  ];

  meta = {
    description = "Mod manager installing MaxLastBreath's UltraCam dynamic-FPS, resolution and free-camera mods for Switch games";
    homepage = "https://www.nxoptimizer.com/";
    # nixpkgs has no cc-by-nc-20 attribute, only the -sa and 3.0/4.0 variants.
    license = {
      spdxId = "CC-BY-NC-2.0";
      fullName = "Creative Commons Attribution Non Commercial 2.0 Generic";
      url = "https://creativecommons.org/licenses/by-nc/2.0/";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
    mainProgram = "nx-optimizer";
  };
}
