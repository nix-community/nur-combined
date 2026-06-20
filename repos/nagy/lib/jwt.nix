{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  convertJwtToJson = pkgs.writeShellApplication {
    name = "convert-jwt-to-json";
    passthru = {
      fromSuffix = ".jwt";
      toSuffix = ".json";
    };
    runtimeInputs = [ pkgs.jwt-cli ];
    text = ''
      exec jwt decode --json "$(cat "$1")"
    '';
  };

  jwtToJson =
    { filename }:
    pkgs.runCommandLocal "jwt-decode.json"
      {
        nativeBuildInputs = [ convertJwtToJson ];
      }
      ''
        convert-jwt-to-json ${filename} > $out
      '';

  importJWT = {
    check = lib.hasSuffix ".jwt";
    __functor =
      _self: filename:
      lib.importJSON (jwtToJson {
        inherit filename;
      });
  };
}
