{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
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

  convertPdfToJson = pkgs.writeShellApplication {
    name = "convert-pdf-to-json";
    passthru = {
      fromSuffix = ".pdf";
      toSuffix = ".json";
    };
    runtimeInputs = [ pkgs.exiftool ];
    text = ''
      exec exiftool -json "$1"
    '';
  };

  importPDF = {
    check = lib.hasSuffix ".pdf";
    __functor =
      _self: filename:
      let
        json =
          pkgs.runCommandLocal "pdf-metadata.json"
            {
              nativeBuildInputs = [ convertPdfToJson ];
            }
            ''
              convert-pdf-to-json ${filename} > $out
            '';
      in
      lib.importJSON json;
  };
}
