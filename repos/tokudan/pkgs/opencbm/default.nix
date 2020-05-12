{ stdenv, fetchFromGitHub,
  pkg-config,
  libusb1, ncurses, which,
  cc65,
}:

stdenv.mkDerivation rec {
  name = "opencbm-${version}";
  version = "git-20191221";

  src = fetchFromGitHub {
    owner = "OpenCBM";
    repo = "OpenCBM";
    rev = "4b1afe5374bffbb733e89121c8ca6afab803ee8f";
    sha256 = "0pxw88gq3dig3kkmsng3s6s61659w72x3zrln5ybxxdasdshnyd5";
  };

  patches = [
    ./01-fix_etc.patch
  ];
  buildInputs = [ pkg-config cc65 libusb1 ncurses which ];
  configureFlags = [  ];
  makefile = "LINUX/Makefile";
  makeFlags = [ "PREFIX=$(out)" "opencbm" "plugin" ];
  installTargets = "install";
  # special treatment necessary for the plugins...
  postInstall = ''
    mkdir -p $out/usr/local/lib
    ln -sf $out/usr/local/lib $out/lib
    mkdir -p $out/etc/udev/rules.d/
    DESTDIR=$out make -f ${makefile} install-plugin
    mv $out/usr/local/bin/xum1541cfg $out/bin/xum1541cfg
    rmdir $out/usr/local/bin
    cat > $out/etc/opencbm.conf <<-EOF
    [plugins]
    default=xum1541

    [xu1541]
    location=$out/usr/local/lib/opencbm/plugin/libopencbm-xu1541.so

    [xum1541]
    location=$out/usr/local/lib/opencbm/plugin/libopencbm-xum1541.so
    EOF
    '';

  meta = with stdenv.lib; {
    description = "Tools to access the Commodore 1541 and similar disk drives from PCs";
    homepage    = https://github.com/OpenCBM/OpenCBM;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ tokudan ];
  };
}

