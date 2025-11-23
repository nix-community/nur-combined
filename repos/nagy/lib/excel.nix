{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  importXLSX =
    filename:
    lib.importJSON (xlsxToJson {
      inherit filename;
    });

  xlsxToJson =
    { filename }:
    pkgs.runCommandLocal "xlsx2json.json" { } (''
      ${xlsxToJsonWriter}/bin/xlsx2json ${filename} > $out
    '');

  xlsxToJsonWriter =
    pkgs.writers.writePython3Bin "xlsx2json" { libraries = ps: [ ps.python-calamine ]; }
      ''
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
      '';
}
