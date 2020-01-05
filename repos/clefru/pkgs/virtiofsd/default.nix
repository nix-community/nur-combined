{ stdenv, fetchurl, fetchpatch, fetchgit, python, zlib, pkgconfig, glib
, ncurses, perl, pixman, vde2, alsaLib, texinfo, flex
, bison, lzo, snappy, libaio, gnutls, nettle, curl
, makeWrapper
, attr, libcap, libcap_ng
, seccompSupport ? stdenv.isLinux, libseccomp
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "0.3";
  pname = "virtiofsd";

  src = fetchgit {
    url = "https://gitlab.com/virtio-fs/qemu.git";
    rev = "32006c66f2578af4121d7effaccae4aa4fa12e46";
    sha256 = "05g5093mi48xcplmmkry8zf751qq9q9wh5hlr4kx0zxk506gqqkr";
  };

  nativeBuildInputs = [ python python.pkgs.sphinx pkgconfig flex bison ];
  buildInputs =
    [ zlib glib ncurses perl pixman
      vde2 texinfo makeWrapper lzo snappy
      gnutls nettle curl
    ]
    ++ optionals seccompSupport [ libseccomp ]
    ++ optionals stdenv.isLinux [ alsaLib libaio libcap_ng libcap attr ];
  
  enableParallelBuilding = true;

  hardeningDisable = [ "stackprotector" ];

  preConfigure = ''
    unset CPP # intereferes with dependency calculation
  '' + optionalString stdenv.hostPlatform.isMusl ''
    NIX_CFLAGS_COMPILE+=" -D_LINUX_SYSINFO_H"
  '';

  configureFlags =
    [ "--sysconfdir=/etc"
      "--localstatedir=/var"
      "--disable-auth-pam"
      "--disable-avx2"
      "--disable-bluez"
      "--disable-bochs"
      "--disable-brlapi"
      "--disable-bzip2"
      "--disable-capstone"
      "--disable-cloop"
      "--disable-curl"
      "--disable-curses"
      "--disable-debug-tcg"
      "--disable-dmg"
      "--disable-docs"
      "--disable-fdt"
      "--disable-glusterfs"
      "--disable-gtk"
      "--disable-guest-agent"
      "--disable-guest-agent-msi"
      "--disable-libiscsi"
      "--disable-libnfs"
      "--disable-libpmem"
      "--disable-libusb"
      "--disable-linux-aio"
      "--disable-lzo"
      "--disable-opengl"
      "--disable-parallels"
      "--disable-qcow1"
      "--disable-qed"
      "--disable-qom-cast-debug"
      "--disable-rdma"
      "--disable-replication"
      "--disable-sdl"
      "--disable-slirp"
      "--disable-smartcard"
      "--disable-snappy"
      "--disable-spice"
      "--disable-tcg"
      "--disable-tcg-interpreter"
      "--disable-tcmalloc"
      "--disable-tools"
      "--disable-tpm"
      "--disable-usb-redir"
      "--disable-vdi"
      "--disable-virglrenderer"
      "--disable-vnc"
      "--disable-vnc-jpeg"
      "--disable-vnc-png"
      "--disable-vnc-sasl"
      "--disable-vte"
      "--disable-vvfat"
      "--disable-vxhs"
      "--disable-xen"
      "--enable-attr"
      "--enable-cap-ng"
      "--enable-kvm"
      "--enable-malloc-trim"
      "--enable-vhost-net"
      "--enable-virtfs"
      "--target-list=x86_64-softmmu"      
    ];

  doCheck = false; # tries to access /dev

  # Build only virtiofsd
  makeFlags = "virtiofsd";

  installPhase = ''
    mkdir -p $out/bin
    install virtiofsd $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = https://virtio-fs.gitlab.io/;
    description = "Daemon to support virtio-fs guest access.";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
