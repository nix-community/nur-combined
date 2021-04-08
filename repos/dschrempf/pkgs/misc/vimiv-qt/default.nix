{ stdenv,
  lib,
  fetchFromGitHub,
  python39Packages,
  qt5 }:

with python39Packages;
buildPythonApplication rec {
  pname = "vimiv-qt";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "karlch";
    repo = pname;
    rev = "v${version}";
    sha256 = "1pj3gak7nxkw9r9m71zsfvcaq8dk9crbk5rz4n7pravxkl5hs2bg";
  };

  nativeBuildInputs = [ qt5.wrapQtAppsHook setuptools ];

  propagatedBuildInputs = [ pyqt5 py3exiv2 qt5.qtsvg ];

  postInstall = ''
	install -Dm644 misc/vimiv.desktop "$out/applications/vimiv.desktop"
	install -Dm644 misc/org.karlch.vimiv.qt.metainfo.xml "$out/metainfo/org.karlch.vimiv.qt.metainfo.xml"
	install -Dm644 LICENSE "$out/licenses/vimiv/LICENSE"
	install -Dm644 misc/vimiv.1 "$out/man/man1/vimiv.1"
	gzip -n -9 -f  "$out/man/man1/vimiv.1"
  ICONSIZES=(16 32 64 128 256 512)
	for i in "''${ICONSIZES[@]}"; do install -Dm644 icons/vimiv_''${i}x''${i}.png "$out/icons/hicolor/''${i}x''${i}/apps/vimiv.png"; done
	install -Dm644 icons/vimiv.svg "$out/icons/hicolor/scalable/apps/vimiv.svg"
  '';

  # This is in the nixpkgs manual. Vimiv has to be wrapped manually because it
  # is a non-ELF executable.
  dontWrapQtApps = true;
  preFixup = ''
      wrapQtApp "$out/bin/vimiv"
  '';

  meta = with lib; {
    description = "";
    license = licenses.gpl3Plus;
    homepage = "https://github.com/karlch/vimiv-qt";
    maintainers = let dschrempf = import ../../dschrempf.nix; in [ dschrempf ];
    platforms = platforms.all;
  };
}
