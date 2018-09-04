{ stdenv, fetchFromGitHub, gdb, makeWrapper, python2Packages }:

stdenv.mkDerivation rec {
  name = "gdb-dashboard-${version}";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "cyrus-and";
    repo = "gdb-dashboard";
    rev = "v${version}";
    sha256 = "1ym1z223q35igabgrb5119cgm8f0mrvp3j3p19maqcc50g6xq6gx";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [ python2Packages.pygments ];

  installPhase = let
  in ''
    mkdir -p $out/share/gdb-dashboard
    cp -r .gdbinit $out/share/gdb-dashboard/gdbinit
    makeWrapper ${gdb}/bin/gdb $out/bin/gdb-dashboard \
      --add-flags "-q -x $out/share/gdb-dashboard/gdbinit"

    p=$(toPythonPath ${python2Packages.pygments})
    sed -i "/import os/a import os; import sys; sys.path[0:0] = '$p'.split(':')" \
       $out/share/gdb-dashboard/gdbinit
  '';

  meta = with stdenv.lib; {
    description = "Modular visual interface for GDB in Python";
    homepage = https://github.com/cyrus-and/gdb-dashboard;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
  };
}
