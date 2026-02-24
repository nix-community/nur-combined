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
      (pkgs.python3.withPackages (ps: [ ps.python-calamine ]))
      (pkgs.writers.writePython3Bin "xlsx2json" { libraries = ps: [ ps.python-calamine ]; } ''
        import json
        import sys
        from python_calamine import CalamineWorkbook
        inputfile = sys.argv[1]
        workbook = CalamineWorkbook.from_path(inputfile)
        all_dict = {}
        for sheet_name in workbook.sheet_names:
            sheet = workbook.get_sheet_by_name(sheet_name)
            all_dict[sheet_name] = []
            rows = iter(sheet.to_python())
            headers = list(map(str, next(rows)))
            for row in rows:
                result_dict = dict(zip(headers, row))
                all_dict[sheet_name].append(result_dict)
        json.dump(all_dict, sys.stdout, indent=2)
        print("")  # final newline
      '')
    ];
    text = ''
      exec xlsx2json "$@"
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
