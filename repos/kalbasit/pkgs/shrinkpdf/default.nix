{ pkgs, lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "shrinkpdf-${version}";
  version = "0.0.1";
  src = fetchurl {
    url = "https://web.archive.org/web/20180730010407/http://www.alfredklomp.com/programming/shrinkpdf/shrinkpdf.sh";
    sha256 = "1iycn5l37m2ymyh3fs9x3gdrfdb45x7mah28f24c1r0wx13kwcdz";
  };

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/shrinkpdf
    substituteInPlace $out/bin/shrinkpdf \
      --replace gs ${pkgs.ghostscript}/bin/gs
  '';

  meta = with lib; {
    description = "shrink PDF files with Ghostscript";
    longDescription = ''
      A simple wrapper around Ghostscript to shrink PDFs (as in reduce
      filesize) under Linux. Inspired by some code I found in an OpenOffice
      Python script (I think). The script feeds a PDF through Ghostscript,
      which performs lossy recompression by such methods as downsampling the
      images to 72dpi.  The result should be (but not always is) a much smaller
      file.
    '';
    homepage = http://www.alfredklomp.com/programming/shrinkpdf/;
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ kalbasit ];
  };
}
