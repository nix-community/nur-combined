{pkgs, ...}: {
  # Document conversion tools: markitdown (Microsoft), pandoc (universal),
  # tesseract (OCR).
  #
  # markitdown requires Python 3.14 overrides in pkgs/default.nix:
  #   - pandas-stubs: pytest parametrize(generator) fails with pytest 9
  #     (used transitively via pdfplumber → markitdown)

  environment.systemPackages = with pkgs; [
    # Microsoft markitdown — PDF, DOCX, PPTX, XLSX, images, audio → Markdown
    # Optimized for LLM/RAG pipelines (token-efficient output).
    python314Packages.markitdown

    # Pandoc — universal document converter (40+ formats)
    # Best for DOCX → Markdown; no PDF input support.
    pandoc

    # Tesseract — OCR engine (images → text)
    # Used by markitdown for image text extraction.
    tesseract
  ];
}
