# FIXME text bbox positions are wrong in the PDF file
# all bboxes are packed in the top-left corner

# FIXME support AVIF image files (etc)

# TODO dont depend on local LLM server
# also offer a standalone tool like
# https://github.com/BartWojtowicz/videopython

# TODO test FastAPI web server: pdf_ocr.server

{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "local-llm-pdf-ocr";
  version = "0-unstable-2026-04-21-f12b8fe";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ahnafnafee";
    repo = "local-llm-pdf-ocr";
    rev = "f12b8fe9040537c28d939756c9323b585577ea21";
    hash = "sha256-Vb206zyprVCmDoy4d+Gu+nDpzsL/Yc/7BlyEedYkWXc=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/>=.*",$/",/' pyproject.toml

    # fix: ModuleNotFoundError: No module named 'src'
    grep -r -l -F " src.pdf_ocr" . |
    grep '\.py$' |
    xargs sed -i 's/ src\.pdf_ocr/ pdf_ocr/'

    # move scripts to package
    mv -t src/pdf_ocr main.py server.py static scripts tests

    # add main script
    # install server assets
    cat >>pyproject.toml <<EOF
    [project.scripts]
    local-llm-pdf-ocr = "pdf_ocr.main:main"

    [tool.setuptools]
    include-package-data = true

    [tool.setuptools.package-data]
    pdf_ocr = ["static/*"]
    EOF

    # fix: print errors
    substituteInPlace src/pdf_ocr/main.py \
      --replace \
        "    except Exception:" \
        "$(
          echo "    except Exception as exc:"
          echo "        raise"
        )"
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    fastapi
    openai
    opencv-python-headless
    pillow
    pymupdf
    python-dotenv
    python-multipart
    rich
    surya-ocr
    torch
    torchvision
    tqdm
    uvicorn
    websockets
  ];

  pythonImportsCheck = [
    "pdf_ocr"
  ];

  # doCheck = false;
  dontUsePytestCheck = true;

  meta = {
    description = "Convert scanned PDFs into searchable text locally using Vision LLMs (olmOCR). 100% private, offline, and free. Features a modern Web UI & CLI";
    homepage = "https://github.com/ahnafnafee/local-llm-pdf-ocr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "local-llm-pdf-ocr";
  };
})
