{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # pytestCheckHook,
  setuptools,
  pdf2image,
  pymupdf,
  opencv-python,
  numpy,
  pillow,
  tqdm,
  doxapy,
  tifffile,
}:

buildPythonPackage rec {
  pname = "binarize-pdf";
  version = "0.1.0-5a9ca49";

  src = fetchFromGitHub {
    owner = "rahimnathwani";
    repo = "binarize-pdf";
    # https://github.com/rahimnathwani/binarize-pdf/pull/2
    rev = "5a9ca491771b1cbd8e83c85b5d0201763e5312ab";
    hash = "sha256-FDuNmRN9b9cLFhsrYf+rheA40EQoN2m+qj64dKRNzD0=";
  };

  pyproject = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pdf2image
    pymupdf
    opencv-python
    numpy
    pillow
    tqdm
    doxapy
    tifffile
  ];

  postInstall = ''
    mv -v $out/bin/binarize-pdf.py $out/bin/binarize-pdf
  '';

  meta = with lib; {
    description = "Convert PDF to black and white using adaptive thresholding";
    homepage = "https://github.com/rahimnathwani/binarize-pdf";
    # TODO add license
    # https://github.com/rahimnathwani/binarize-pdf/issues/1
    license = licenses.unfree;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "binarize-pdf";
    platforms = platforms.all;
  };
}
