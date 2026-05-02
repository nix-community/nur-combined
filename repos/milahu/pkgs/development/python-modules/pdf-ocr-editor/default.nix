{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pdf-ocr-editor";
  version = "0-unstable-2026-01-13";

  src = fetchFromGitHub {
    owner = "jbrest";
    repo = "pdf_ocr_editor";
    rev = "ea98c6a3438dc3c9f1b2c2b0754701cdac0d25f1";
    hash = "sha256-gaij3KkO9QK2LKNYHkwB+q16HwHx7GATZK76XXiJ498=";
  };

  pyproject = true;

  postPatch = ''
    mv -v pdf_ocr_editor.py pdf-ocr-editor.py

    cat >requirements.txt <<EOF
    pymupdf
    EOF

    cat >setup.py <<EOF
    from setuptools import setup
    with open('requirements.txt') as f:
        install_requires = f.read().splitlines()
    setup(
      name='pdf-ocr-editor',
      #packages=['someprogram'],
      version='0.1.0',
      #author='...',
      #description='...',
      install_requires=install_requires,
      scripts=[
        'pdf-ocr-editor.py',
      ],
      entry_points={
        # example: file some_module.py -> function main
        #'console_scripts': ['someprogram=some_module:main']
      },
    )
    EOF
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    pymupdf
  ];

  pythonImportsCheck = [
  ];

  # doCheck = false; # no effect
  dontUsePytestCheck = true;

  meta = {
    description = "Edit invisible text in OCR PDF documents";
    homepage = "https://github.com/jbrest/pdf_ocr_editor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pdf-ocr-editor.py";
    platforms = lib.platforms.all;
  };
})
