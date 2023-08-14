# https://github.com/NixOS/nixpkgs/issues/230167
{ lib
, python3Packages
, SDL2
, libjpeg
, gobject-introspection
, fetchFromGitHub
, wrapGAppsHook
, glib
, gtk4
}:

python3Packages.buildPythonApplication rec {
  pname = "cameractrls";
  version = "0.5.10";

  src = fetchFromGitHub {
    owner = "soyersoyer";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-boOuFF5cJso8X/YuRzxpqaD1ByMd7qS+OPtl57+4k5k=";
  };

  format = "other";

  dontBuild = true;

  buildInputs = [
    SDL2
    libjpeg
    gtk4
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp cameractrls.py $out/share
    cp cameractrlsgtk4.py $out/bin/cameractrls-gtk
  '';

  makeWrapperArgs = [
    "--prefix PYTHONPATH : ${placeholder "out"}/share"
  ];
}
