{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  zathura,
}:

stdenv.mkDerivation rec {
  pname = "zaread";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/paoloap/zaread/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-w7cfZ/zkY11lKwcF1HIjGOwZWwy/vP5H7TDxCo8b02E=";
  };

  sourceRoot = "${pname}-${version}";

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # https://github.com/NixOS/nixpkgs/blob/b1b875982b17dabde9b4a37f3e229e74913e6db3/pkgs/applications/misc/zathura/wrapper.nix#L41-L44
  installPhase = ''
    runHook preInstall

    make install DEST=$out
    wrapProgram $out/bin/zaread \
      --prefix PATH ":" "${lib.makeBinPath [ zathura ]}"

    runHook postInstall
  '';

  meta = {
    description = "A (very) lightweight MS Office file reader";
    longDescription = ''
      ### What file formats does zaread support?

      - PDF, DJVU, EPUB (opened directly via zathura)
      - OOXML documents (docx, xlsx, pptx, and macro-enabled variants like xlsm, docm, pptm)
      - Old MS Office documents (doc, xls, ppt)
      - OpenDocument formats (odt, ods, odp)
      - Other Office formats (xlsb, ppsx, dotx)
      - MOBI
      - CSV, RTF
      - Markdown (md)
      - Typst (typ)

      ### What about optional dependences?

      - **pkgs.libreoffice** (`soffice`) -- for Office documents, CSV, and RTF. Unfortunately there's no lighter alternative for converting Office files on Linux.
      - **pkgs.calibre** (`ebook-convert`) -- for MOBI. Same story.
      - **pkgs.md2pdf** -- for Markdown. Has some Python dependencies but it's a better option than the old pandoc approach, which needed the whole texlive suite.
      - **pkgs.typst** -- for Typst documents.

      ### Can I use a different PDF viewer?

      Yes. Create a config file at `~/.config/zaread/zareadrc` (or `$XDG_CONFIG_HOME/zaread/zareadrc`) and override any of the default variables:

      ```sh
      # Reader
      READER="zathura"
      READER_ARG=""

      # Converters
      OFFICE_CMD="soffice"       # LibreOffice
      OFFICE_ARG=""
      MOBI_CMD="ebook-convert"   # calibre
      MOBI_ARG=""
      MD_CMD="md2pdf"
      MD_ARG=""
      TYPST_CMD="typst"
      TYPST_ARG="compile"

      # Behavior
      VERBOSE=0
      ```

      The config is sourced as shell, so anything you set there takes effect at runtime.
    '';
    homepage = "https://github.com/paoloap/zaread";
    downloadPage = "https://github.com/paoloap/zaread/releases";

    license = with lib.licenses; [
      gpl3Only
    ];
    platforms = lib.platforms.all;
  };
}
