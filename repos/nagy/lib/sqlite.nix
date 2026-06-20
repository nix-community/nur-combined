{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  convertSqliteToJson = pkgs.writeShellApplication {
    name = "convert-sqlite-to-json";
    passthru = {
      fromSuffix = ".db";
      toSuffix = ".json";
    };
    runtimeInputs = [ pkgs.sqlite ];
    text = ''
      exec sqlite3 -json "$1" "SELECT * FROM sqlite_master"
    '';
  };

  sqliteToJson =
    { filename }:
    pkgs.runCommandLocal "sqlite-schema.json"
      {
        nativeBuildInputs = [ convertSqliteToJson ];
      }
      ''
        convert-sqlite-to-json ${filename} > $out
      '';

  importSQLITE = {
    check = lib.hasSuffix ".db";
    __functor = _self: filename:
      lib.importJSON (sqliteToJson {
        inherit filename;
      });
  };
}
