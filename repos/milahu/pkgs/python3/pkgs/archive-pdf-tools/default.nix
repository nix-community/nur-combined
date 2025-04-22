/*

TODO add dependencies

One-of:

  Open source OpenJPEG2000 tools (opj_compress and opj_decompress)
    openjpeg
  Grok (grk_compress and grk_decompress)
  jpegoptim (when using JPEG instead of JPEG2000)
    jpegoptim

For JBIG2 compression:

  jbig2enc for JBIG2 compression (and PyMuPDF 1.19.0 or higher)
    jbig2enc

*/

{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "archive-pdf-tools";
  version = "1.5.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-pdf-tools";
    rev = version;
    hash = "sha256-tkCJ1PLyKkiV80jrimuSY2nSnsOH0eArsla5+GQ4HV4=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    archive-hocr-tools
    cython
    numpy
    pillow
    pymupdf
    roman
    scikit-image
    scipy
    xmltodict
    lxml
  ];

  pythonImportsCheck = [ "internetarchivepdf" ];

  meta = with lib; {
    description = "Fast PDF generation and compression. Deals with millions of pages daily";
    homepage = "https://github.com/internetarchive/archive-pdf-tools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "internetarchivepdf";
  };
}
