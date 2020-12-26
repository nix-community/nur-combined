{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sxmo-xdm-config";
  version = "0.2.1";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-xdm-config";
    rev = "${version}";
    sha256 = "173k4mydy6s4yff9sj3x0jnykvzfq231z0dzyq27lgfiwizpn1jg";
  };

  postPatch = ''
    sed -i "s@/usr/lib@/lib@g" Makefile 
    sed -i "s@chmod@\#@g" Makefile 
  '';

  preBuild = ''
    export DESTDIR=$out
    mkdir -p $out/etc/X11/xdm
    mkdir -p $out/lib/X11/xdm
    mkdir -p $out/etc/conf.d/xdm
    mkdir -p $out/etc/profile.d
  '';

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-xdm-config";
    description = "XDM configuration for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = stdenv.lib.platforms.all; 
  };
}