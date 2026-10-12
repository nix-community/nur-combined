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
  buildPythonApplication {
    pname = "hypruse";
    version = "0.12.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "IlyasKhallouki";
      repo = "hypruse";
      rev = "1fa80b026454a527c4acfb49b32017ad999f9335";
      hash = "sha256-Q25kQpI5BLeAm9D6C7pr0PEu/zEY77aC/jp0hzMjQXo=";
    };

    build-system = [hatchling];
    dependencies = [mcp];
    nativeCheckInputs = [pytestCheckHook];
    pythonImportsCheck = ["hypruse"];

    # Test the installed wheel's skill rather than the checkout-only location.
    postPatch = ''
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
