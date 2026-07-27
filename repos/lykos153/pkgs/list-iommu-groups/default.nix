{ stdenv
, lib
, fetchurl
, pciutils
, usbutils
}:

stdenv.mkDerivation rec {
  name = "shrinkpdf";
  src = fetchurl
  {
    url = "https://gist.githubusercontent.com/r15ch13/ba2d738985fce8990a4e9f32d07c6ada/raw/05712e1581a187fcfc97b984c0c6a6e70db7b884/iommu.sh";
    hash = "sha256-TJpKciOy+5SEGn9l/UuhOMiqjAhgDUYwWMKcgN4IcxQ=";
  };

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/list-iommu-groups
    substituteInPlace $out/bin/list-iommu-groups \
      --replace lspci ${pciutils}/bin/lspci \
      --replace lsusb ${usbutils}/bin/lsusb
  '';

  meta = with lib; {
    description = " List IOMMU Groups and the connected USB Devices";
    homepage = "https://gist.github.com/r15ch13/ba2d738985fce8990a4e9f32d07c6ada";
    platforms = platforms.all;
  };
}
