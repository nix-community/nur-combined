{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  xlsxToJson =
    { filename }:
    pkgs.runCommandLocal "xlsx2json.json"
      {
        nativeBuildInputs = [ convertXlsxToJson ];
      }
      ''
        convert-xlsx-to-json ${filename} > $out
      '';

  convertXlsxToJson = pkgs.writeShellApplication {
    name = "convert-xlsx-to-json";
    passthru = {
      fromSuffix = ".xlsx";
      toSuffix = ".json";
    };
    runtimeInputs = [
      pkgs.xleak
    ];
    text = ''
      exec xleak --export json "$@"
    '';
  };

  importXLSX = {
    check = lib.hasSuffix ".xlsx";
    __functor =
      _self: filename:
      lib.importJSON (xlsxToJson {
        inherit filename;
      });
  };

}
