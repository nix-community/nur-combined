{ stdenv, lib, fetchFromGitHub, python3Packages, glib, cairo, pango, pkgconfig, libxcb, xcbutilcursor }:

let cairocffi-xcffib = python3Packages.cairocffi.override {
    withXcffib = true;
  };
in

python3Packages.buildPythonApplication rec {
  name = "qtile-${version}";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "qtile";
    repo = "qtile";
    rev = "v${version}";
    sha256 = "1fcfd6cj0q5qlg8myj1acg1kfxz1m9qd6fcqdhwpmnnigvsc8x67";
  };

  # patches = [
  #   ./0001-Substitution-vars-for-absolute-paths.patch
  #   ./0002-Restore-PATH-and-PYTHONPATH.patch
  #   ./0003-Restart-executable.patch
  # ];

  # postPatch = ''
  #   substituteInPlace libqtile/manager.py --subst-var-by out $out
  #   substituteInPlace libqtile/pangocffi.py --subst-var-by glib ${glib.out}
  #   substituteInPlace libqtile/pangocffi.py --subst-var-by pango ${pango.out}
  #   substituteInPlace libqtile/xcursors.py --subst-var-by xcb-cursor ${xcbutilcursor.out}
  # '';

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ glib libxcb cairo pango python3Packages.xcffib ];

  pythonPath = with python3Packages; [ xcffib cairocffi-xcffib setuptools ];

  postInstall = ''
    wrapProgram $out/bin/qtile \
      --set LD_LIBRARY_PATH "${lib.getLib glib}/lib:${lib.getLib pango}/lib"
  '';

  doCheck = false; # Requires X server.

  meta = with lib; {
    homepage = "http://www.qtile.org/";
    license = licenses.mit;
    description = "A small, flexible, scriptable tiling window manager written in Python";
    platforms = platforms.linux;
    maintainers = with maintainers; [ kamilchm ];
  };
}
