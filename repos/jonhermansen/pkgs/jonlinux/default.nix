{ stdenv
, fetchurl
, gcc_multi
, glibc_multi
, bison
, flex
, lib
, bc
}:

stdenv.mkDerivation rec {
  pname = "jonlinux";
  version = "6.15.6";

  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "sha256-K7WGyVQnfQcMj99tcnX6qTtIB9m/M1O0kdgUnMoCtPw=";
  };

  nativeBuildInputs = [ bc bison flex gcc_multi glibc_multi ];

  unpackPhase = ''
    tar xf $src
    cd linux-${version}
  '';

  buildPhase = ''
    sed -i '/^KBUILD_CFLAGS/s/-mcmodel=large//' arch/x86/um/Makefile # still needed?
    make defconfig ARCH=um
    make ARCH=um
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp linux $out/bin/

    cat > $out/bin/run-uml <<EOF
#!/bin/sh
exec "\$0_dir/linux" \\
  root=/dev/root \\
  rootfstype=hostfs \\
  rw \\
  init=/bin/sh \\
  mem=128M \\
  debug
EOF
    chmod +x $out/bin/run-uml
    substituteInPlace $out/bin/run-uml --replace "\$0_dir" "\$(dirname \$0)"
  '';

  meta = {
    description = "UML Linux kernel ${version} with hostfs support";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
