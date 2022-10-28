{
  lib,
  callPackage,
  buildPythonPackage,
  qt5,
  pytest,
  mock,
  babel,
  pyqt5,
  xlib,
  pyserial,
  appdirs,
  wcwidth,
  setuptools,
  pywayland,
  xkbcommon,
  wayland,
  pkg-config,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  plover-stroke = callPackage ../plover-stroke.nix {};
  rtf-tokenize = callPackage ../../python/rtf-tokenize.nix {};
in
  qt5.mkDerivationWith buildPythonPackage rec {
    pname = "plover";
    version = source.date;
    src = callPackage ./source.nix {};

    # I'm not sure why we don't find PyQt5 here but there's a similar
    # sed on many of the platforms Plover builds for
    postPatch = ''
      sed -i /PyQt5/d setup.cfg
      sed -i 's/pywayland==0.4.11/pywayland>=0.4.11/' reqs/constraints.txt
      substituteInPlace plover_build_utils/setup.py \
        --replace "/usr/share/wayland/wayland.xml" "${wayland}/share/wayland/wayland.xml"
    '';

    checkInputs = [pytest mock];
    propagatedBuildInputs = [babel pyqt5 xlib pyserial appdirs wcwidth setuptools plover-stroke rtf-tokenize pywayland xkbcommon];
    nativeBuildInputs = [
      wayland
      pkg-config
    ];

    installCheckPhase = "true";

    dontWrapQtApps = true;

    preFixup = ''
      makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    '';

    meta = {
      homepage = "http://www.openstenoproject.org/";
      description = "Open Source Stenography Software, patched with wayland support";
      license = lib.licenses.gpl2Plus;
    };
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://github.com/openstenoproject/plover"
      "plover/plover/source.json"
    ];
  }
