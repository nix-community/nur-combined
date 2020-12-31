{ stdenv, fetchgit, libX11 }:

stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  version = "1.2.0";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-utils";
    rev = "${version}";
    sha256 = "0pnn5fh9gsn7dzvy805ij41n3c6qr2m1l6ws8mnfdlz1kw6z7adr";
  };

  patches = [
    ./0001-remove-shellcheck.patch
    ./0001-Use-pidof-instead-of-pkill-to-select-lisgid.patch
    ./0001-Account-for-edge-case-where-none-appears-in-lsof-out.patch
  ];

  postPatch = ''
    # patch out hardcoded paths in makefile
    sed -i "s@PREFIX:=/@PREFIX=$out@g" Makefile 
    sed -i "s@/usr/share@/share@g" Makefile 
    sed -i "s@/usr/bin@/bin@g" Makefile 
    sed -i "s@gcc@$CC@g" Makefile 
    sed -i "s@chown@\#@g" Makefile 
    sed -i "s@chmod@\#@g" Makefile 

    # patch out hardcoded paths in utils
    find . -type f -exec sed -i "s@/usr/share/sxmo@$out/share/sxmo@g" {} +
    find . -type f -exec sed -i "s@/usr/share/applications@$out/share/applications@g" {} +
    find . -type f -exec sed -i "s@/usr/share/zoneinfo@/etc/zoneinfo@g" {} +
    sed -i "s@/usr/libexec/geoclue-2.0/demos/where-am-i@where-am-i@g" scripts/core/sxmo_gpsutil.sh
    sed -i "s@/usr/bin@@g" configs/appcfg/dunst.conf
    sed -i "s@/usr/bin@@g" configs/udev/50-sxmo.rules
  '';

  buildInputs = [
    libX11
  ];

  buildPhase = "";
  installPhase = "make install";

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-utils";
    description = "Scripts and small C programs for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = stdenv.lib.platforms.linux; 
  };
}
