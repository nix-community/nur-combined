{
  fetchurl,
  lib,
  stdenv,
  qt5,
}:
stdenv.mkDerivation rec {
  pname = "gowin-eda-edu-ide";
  version = "1.9.11.01";

  src = fetchurl {
    # https://www.gowinsemi.com.cn/faq.aspx
    url = "https://cdn.gowinsemi.com.cn/Gowin_V${version}_Education_Linux.tar.gz";
    sha256 = "sha256-I26TSznMquS74NZzgJtRDMQ4V9hg7z4WCSJ0ybkvrQ4=";
  };
  sourceRoot = ".";

  buildInputs = [qt5.qtbase];
  nativeBuildInputs = [qt5.wrapQtAppsHook];

  installPhase = ''
    _package-ide() {
      # install IDE
      cd IDE
      find doc/              -type f -exec install -Dm644 {} $out/{} \;
      find lib/              -type f -exec install -Dm644 {} $out/{} \;
      find data/             -type f -exec install -Dm644 {} $out/{} \;
      find share/            -type f -exec install -Dm644 {} $out/{} \;
      find simlib/           -type f -exec install -Dm644 {} $out/{} \;
      find ipcore/           -type f -exec install -Dm644 {} $out/{} \;
      find plugins/          -type f -exec install -Dm644 {} $out/{} \;
      find bin/vhdl_packages -type f -exec install -Dm644 {} $out/{} \;
      find bin/              -type f -exec install -Dm755 {} $out/{} \;

      chmod 644 $out/bin/prim{itive.xml,_syn.vhd,_syn.v}
      chmod 644 $out/bin/qt.conf
      chmod 644 $out/bin/programmer.json

      # fix ide launch error
      # libfreetype.so.6 from Gowin EDA ide could cause error when launch the IDE:
      # /opt/gowin-eda-edu-ide/bin/gw_ide: symbol lookup error: /usr/lib/libfontconfig.so.1: undefined symbol: FT_Done_MM_Var
      #
      # https://bbs.archlinux.org/viewtopic.php?id=251445
      # https://mathematica.stackexchange.com/questions/189306/cant-launch-mathematica-11-on-fedora-29
      rm -f $out/lib/libfreetype.so.6
    }
    _package-ide
  '';

  meta = with lib; {
    description = "Gowin EDA, an easy to use integrated design environment provides design engineers one-stop solution from design entry to verification. (education version)";
    homepage = "http://www.gowinsemi.com.cn/faq.aspx";
    maintainers = with maintainers; [];
  };
}
