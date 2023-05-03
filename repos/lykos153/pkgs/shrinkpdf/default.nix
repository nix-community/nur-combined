{ stdenv
, lib
, fetchFromGitHub
, ghostscript
}:

stdenv.mkDerivation rec {
  name = "shrinkpdf";
  # renovate: datasource=github-releases depName=aklomp/shrinkpdf extractVersion=^shrinkpdf-(?<version>.+)$
  version = "1.1";
  src = fetchFromGitHub
  {
    owner = "aklomp";
    repo = name;
    rev = "v${version}";
    hash = "sha256-SGsJW/meVs2MxywbqcgylvsKGuFck1x1vxb1gyXnJAk=";
  } + "/shrinkpdf.sh";

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/shrinkpdf
    substituteInPlace $out/bin/shrinkpdf \
      --replace gs ${ghostscript}/bin/gs
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
    homepage = https://github.com/aklomp/shrinkpdf;
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
