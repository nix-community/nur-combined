{ stdenv
, lib
, fetchurl
, cmake
, pkg-config
, libGLU
, libGL
, gtk2
, gnome2
}:

stdenv.mkDerivation rec {
  pname = "luscus";
  version = "0.8.6";

  src = fetchurl {
    url = "mirror://sourceforge/project/luscus/luscus_${version}.tar.gz";
    sha256 = "18vkqn29lgix08bxrmnpvrzj575402disg9bqa41qvkbb3g0igz1";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace '"$ENV{HOME}/.luscus"' "$out/etc"
    substituteInPlace gv_system.c --replace "/etc/luscus" "$out/etc"
    for i in $(find -name "*.sh"); do
      substituteInPlace $i --replace '$HOME/.luscus/' "$out/bin/"
    done

    #sed -i "s|\$RUNDIR/|$out/bin/|" ./*/*/*.sh
  '';

  # This is missing for some reason:
  LDFLAGS = "-lGLU";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libGLU libGL gtk2 gnome2.gtkglext ];

  postInstall = ''
    find ../ -name "babel_*.sh" -exec install -m 755 \{} $out/bin \; -print
  '';

  meta = with lib; {
    description = "Portable GUI for MOLCAS and other quantum chemical software";
    homepage = "http://luscus.sourceforge.net";
    license = licenses.afl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

