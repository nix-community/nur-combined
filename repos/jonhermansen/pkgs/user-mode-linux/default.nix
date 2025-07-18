{
  stdenv,
  fetchurl,
  gcc_multi,
  glibc_multi,
  bison,
  flex,
  lib,
  bc,
}:

stdenv.mkDerivation rec {
  pname = "user-mode-linux";
  version = "6.15.6";

  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "sha256-K7WGyVQnfQcMj99tcnX6qTtIB9m/M1O0kdgUnMoCtPw=";
  };

  # mainline = fetchurl {
  #   version = "6.16-rc6";
  #   url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
  #   sha256 = "sha256-A7WGyVQnfQcMj99tcnX6qTtIB9m/M1O0kdgUnMoCtPw=";
  # };

  # longterm = fetchurl {
  #   version = "6.12.38";
  #   url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
  #   sha256 = "sha256-F7WGyVQnfQcMj99tcnX6qTtIB9m/M1O0kdgUnMoCtPw=";
  # };

  nativeBuildInputs = [
    bc
    bison
    flex
    gcc_multi
    glibc_multi
  ];

  #  unpackPhase = ''
  #    tar xf $src
  #    cd linux-${version}
  #  '';

  buildPhase = ''
    sed -i '/^KBUILD_CFLAGS/s/-mcmodel=large//' arch/x86/um/Makefile # still needed?
    make defconfig ARCH=um
    make -j$NIX_BUILD_CORES linux ARCH=um
  '';

  installPhase = ''
        mkdir -p $out/bin
        cp linux $out/bin/

        cat > $out/bin/run-uml <<EOF
    #!/bin/sh
    "\$0_dir/linux" \\
      root=/dev/root \\
      rootfstype=hostfs \\
      ro \\
      init=/bin/sh \\
      mem=256M \\
      debug \\
      $*
    reset
    EOF
        chmod +x $out/bin/run-uml
        substituteInPlace $out/bin/run-uml --replace-fail "\$0_dir" "\$(dirname \$0)"
  '';

  meta = {
    description = "UML Linux kernel ${version} with hostfs support";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ]; # builds as i686 on x86_64? wtf
    mainProgram = "run-uml";
  };
}
