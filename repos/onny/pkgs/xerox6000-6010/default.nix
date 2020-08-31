{ stdenv, fetchurl, unzip, rpm, cpio} :
stdenv.mkDerivation {
  pname = "Xerox-Phaser-6000-6010";
  #version = "1.01_20110222";
  version = "1.01_20110226";

  buildInputs = [rpm cpio unzip];

  src = fetchurl {
    url = "http://download.support.xerox.com/pub/drivers/6000/drivers/linux/en_GB/6000_6010_rpm_1.01_20110222.zip";
    sha256 = "1wig2plv94rffna2qc772sgi5dqpxwy2kw3kxqc8gq9zm393gd1w";
  };


  unpackPhase = ''
    unzip $src
    rpm2cpio rpm_1.01_20110222/Xerox-Phaser_6000_6010-1.0-1.i686.rpm | cpio -idmv
    gunzip usr/share/cups/model/Xerox/Xerox_Phaser_6000B.ppd.gz
    gunzip usr/share/cups/model/Xerox/Xerox_Phaser_6010N.ppd.gz
    for i in usr/share/cups/model/Xerox/*.ppd; do
      sed -i $i -e \
        "s,/usr,$out,g"
    done;
  '';

  installPhase = ''
    mkdir -p $out
    mv usr/share $out/
    mv usr/lib $out/
  '';


  meta = with stdenv.lib; {
    homepage = https://www.xerox.com/;
    description = "Print drivers for Xerox Phaser 6000/6100 (DN/DT/N)";
    license = licenses.mit; # licenses.unfreeRedistributable;
    platforms = platforms.linux;
    downloadPage = "https://www.support.xerox.com/support/phaser-6280/downloads/enus.html?operatingSystem=linux&fileLanguage=en";
  };
}
