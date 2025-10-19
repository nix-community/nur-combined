{
  lib,
  stdenv,
  pins,
  unzip,
  rpmextract,
  perl,
}:
stdenv.mkDerivation rec {
  pname = "sfutils";
  version = "8.2.4.1004";

  src = pins.sfutils.outPath;

  nativeBuildInputs = [
    unzip
    rpmextract
    perl
  ];

  unpackPhase = ''
    unzip -qq "$src"
    rpmextract *.rpm
    tar -xvf sfutils-${version}.tar.gz
    cd sfutils-${version}
  '';

  postPatch = ''
    patchShebangs scripts/
    substituteInPlace app/sfupdate/Makefile.in \
      --replace /usr/share/sfutils/sfupdate_images $out/share/sfutils/sfupdate_images
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv build/linux/host/{include,lib,share} $out/
    mv build/linux/host/libexec/*/* $out/bin
    mkdir -p $out/share/sfutils/
    cp -r sfupdate_images $out/share/sfutils/
    cp LICENSE $out/share/sfutils/
  '';

  meta = with lib; {
    description = "Solarflare Utilities for updating firmware, configuring boot ROMs, managing license keys, and configuring driver/hardware parameters";
    homepage = "https://www.xilinx.com/support/download/nic-software-and-drivers.html";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = {
      fullName = "Xilinx license for ${pname} ${version}";
      free = false;
      # NOTE: Doesn't appear to be hosted online in a directly viewable
      # fashion, but is contained in the src tarball
    };
  };
}
