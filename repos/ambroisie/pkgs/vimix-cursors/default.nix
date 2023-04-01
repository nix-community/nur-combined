{ lib, python3, fetchFromGitHub, inkscape, stdenvNoCC, xcursorgen }:
let
  py = python3.withPackages (ps: with ps; [ cairosvg ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "vimix-cursors";
  version = "unstable-2020-04-28";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = "27ebb1935944bc986bf8ae85ee3343b8351d9823";
    hash = "sha256-bIPRrKaNQ2Eo+T6zv7qeA1z7uRHXezM0yxh+uqA01Gs=";
  };

  nativeBuildInputs = [
    inkscape
    py
    xcursorgen
  ];

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    HOME="$NIX_BUILD_ROOT" ./build.sh
  '';

  installPhase = ''
    install -dm 755 $out/share/icons
    for color in "" "-white"; do
      cp -pr dist''${color}/  "$out/share/icons/Vimix''${color}-cursors"
    done
  '';

  meta = with lib; {
    description = "An X cursor theme inspired by Materia design";
    homepage = "https://github.com/vinceliuice/Vimix-cursors";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
