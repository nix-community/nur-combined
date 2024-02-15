{
  fetchFromSourcehut,
  lib,
  scdoc,
  shellcheck,
  stdenvNoCC,
  coreutils,
  dmenu,
  libnotify,
  fzf,
  xdotool,
  defaultNotifier ? libnotify,
  defaultMenu ? dmenu,
  defaultFuzzyFinder ? fzf,
  keyTool ? xdotool,
}: let
  inherit (lib) getExe getExe';
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "pass-sxatm";
    version = "0.2.3";
    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "pass-sxatm";
      rev = finalAttrs.version;
      hash = "sha256-gINSXgrf787xWuHWl1sYqHIZ/kXQYjYtDlKPjeA7Jzo=";
    };

    nativeBuildInputs = [scdoc];

    nativeCheckInputs = [shellcheck];

    makeFlags = ["PREFIX=${builtins.placeholder "out"}"];

    postPatch = ''
      substituteInPlace ./sxatm.bash \
        --replace ':-"dmenu"' ':-"${getExe defaultMenu}"' \
        --replace ':-"notify-send"' ':-"${getExe defaultNotifier}"' \
        --replace ':-"fzf"' ':-"${getExe defaultFuzzyFinder}"' \
        --replace 'command xdotool' 'command ${getExe keyTool}' \
        --replace 'tty ' '${getExe' coreutils "tty"} '
    '';

    meta = with lib; {
      description = "A simple X autofill tool with menu for pass";
      homepage = "https://sr.ht/~onemoresuza/pass-sxatm/";
      downloadPage = "https://git.sr.ht/~onemoresuza/pass-sxatm/refs/${version}";
      license = licenses.gpl2Plus;
      platforms = platforms.all;
    };
  })
