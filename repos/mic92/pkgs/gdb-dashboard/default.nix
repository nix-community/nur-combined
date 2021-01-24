{ stdenv, fetchFromGitHub, gdb, makeWrapper, python3Packages }:

stdenv.mkDerivation rec {
  name = "gdb-dashboard-${version}";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "cyrus-and";
    repo = "gdb-dashboard";
    rev = "v${version}";
    sha256 = "sha256-m+kXbgez4AvVa/siygdefqjRz0dW0G8oEUhwQFNaOU8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [ python3Packages.pygments ];

  installPhase = ''
    mkdir -p $out/share/gdb-dashboard
    cp -r .gdbinit $out/share/gdb-dashboard/gdbinit
    makeWrapper ${gdb}/bin/gdb $out/bin/gdb-dashboard \
      --add-flags "-q -x $out/share/gdb-dashboard/gdbinit"

    p=$(toPythonPath ${python3Packages.pygments})
    sed -i "/import os/a import os; import sys; sys.path[0:0] = '$p'.split(':')" \
       $out/share/gdb-dashboard/gdbinit
  '';

  meta = with stdenv.lib; {
    description = "Modular visual interface for GDB in Python";
    homepage = "https://github.com/cyrus-and/gdb-dashboard";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
  };
}
