{
  # keep-sorted start
  fetchFromGitHub,
  grim,
  imagemagick,
  lib,
  python3Packages,
  systemd,
  wtype,
  # keep-sorted end
  libxkbcommon,
}: let
  inherit (lib) makeBinPath;
  inherit
    (python3Packages)
    # keep-sorted start
    buildPythonApplication
    hatchling
    mcp
    pytestCheckHook
    # keep-sorted end
    ;

  runtimePath = makeBinPath [
    # keep-sorted start
    grim
    imagemagick
    systemd
    wtype
    # keep-sorted end
  ];
in
  buildPythonApplication rec {
    pname = "hypruse";
    version = "0.13.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "IlyasKhallouki";
      repo = "hypruse";
      tag = "v${version}";
      hash = "sha256-xzUYZlbMin3ISIgWj34+6FJsx+o4jXHcxHXHeZ7T7g0=";
    };

    build-system = [hatchling];
    dependencies = [mcp];
    nativeCheckInputs = [pytestCheckHook];
    pythonImportsCheck = ["hypruse"];

    # Test the installed wheel's skill rather than the checkout-only location.
    postPatch = ''
      substituteInPlace src/hypruse/keymap.py tests/test_keymap.py \
        --replace-fail 'ctypes.util.find_library("xkbcommon")' '"${lib.getLib libxkbcommon}/lib/libxkbcommon.so.0"'
      substituteInPlace tests/test_skill.py \
        --replace-fail 'ROOT / "skills" / "hypruse"' 'Path(skill.__file__).resolve().parent / "skill"'
    '';

    # Use hyprctl from the running compositor, not a separately pinned Hyprland.
    makeWrapperArgs = ["--prefix PATH : ${runtimePath}"];

    meta = with lib; {
      # keep-sorted start
      description = "Hyprland computer use over MCP with native Wayland input";
      homepage = "https://github.com/IlyasKhallouki/hypruse";
      license = licenses.mit;
      mainProgram = "hypruse";
      platforms = platforms.linux;
      # keep-sorted end
    };
  }
