{
  pkgs,
  lib ? pkgs.lib,
}:

{
  mkPdfEncrypted =
    {
      file,
      password,
    }:
    pkgs.runCommandLocal "output.pdf"
      {
        src = lib.cleanSource file;
        nativeBuildInputs = [ pkgs.pdftk ];
        env = {
          inherit file password;
        };
      }
      ''
        pdftk "$src" output output.pdf user_pw PROMPT <<< "$password"
        install -Dm644 -t "$out" output.pdf
      '';

  convertPdfToText = pkgs.writeShellApplication {
    name = "convert-pdf-to-text";
    passthru = {
      fromSuffix = ".pdf";
      toSuffix = ".txt";
    };
    runtimeInputs = [ pkgs.poppler-utils ];
    text = ''
      exec pdftotext -layout -nopgbrk "$@" -
    '';
  };

  convertPdfToPng = pkgs.writeShellApplication {
    name = "convert-pdf-to-png";
    passthru = {
      fromSuffix = ".pdf";
      toSuffix = ".png";
    };
    runtimeInputs = [ pkgs.poppler-utils ];
    text = ''
      FILENAME="$1"
      shift
      exec pdftoppm -singlefile -png "$FILENAME" "$FILENAME"
    '';
  };
}
