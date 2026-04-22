{
  lib,
  python3,
  fetchFromGitHub,
  jbig2enc,
  jpegoptim,
  openjpeg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "archive-pdf-tools";
  version = "1.5.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-pdf-tools";
    tag = finalAttrs.version;
    hash = "sha256-FBozPQxpdG4hmeCR3bd7splB9+Jn6VV22uwFdp/wU4I=";
  };

  # TODO
  /*
  --jpeg2000-implementation kakadu
  internetarchivepdf/jpeg2000.py
  KDU_COMPRESS = 'kdu_compress'
  KDU_EXPAND = 'kdu_expand'

  --jpeg2000-implementation grok
  internetarchivepdf/jpeg2000.py
  GRK_COMPRESS = 'grk_compress'
  GRK_DECOMPRESS = 'grk_decompress'
  */

  postPatch = ''
    substituteInPlace internetarchivepdf/mrc.py \
      --replace \
        "args = ['jbig2'" \
        "args = ['${jbig2enc}/bin/jbig2'" \
      --replace \
        "args = ['jpegoptim'" \
        "args = ['${jpegoptim}/bin/jpegoptim'"

    substituteInPlace internetarchivepdf/jpeg2000.py \
      --replace \
        "OPJ_COMPRESS = 'opj_compress'" \
        "OPJ_COMPRESS = '${openjpeg}/bin/opj_compress'" \
      --replace \
        "OPJ_DECOMPRESS = 'opj_decompress'" \
        "OPJ_DECOMPRESS = '${openjpeg}/bin/opj_decompress'"
  '';

  build-system = [
    python3.pkgs.cython
    python3.pkgs.numpy
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    archive-hocr-tools
    cython
    importlib-resources
    numpy
    pillow
    pymupdf
    pywavelets
    roman
    scikit-image
    scipy
    xmltodict
  ];

  meta = {
    description = "Fast PDF generation and compression. Deals with millions of pages daily";
    homepage = "https://github.com/internetarchive/archive-pdf-tools";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    # compress-pdf-images  epub-to-pdf  pdfcomp  pdf-metadata-json  recode_pdf
    mainProgram = "recode_pdf";
  };
})
