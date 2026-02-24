{
  pkgs,
  lib ? pkgs.lib,
}:

rec {

  convertWasmToWat = pkgs.writeShellApplication {
    name = "convert-wasm-to-wat";
    passthru = {
      fromSuffix = ".wasm";
      toSuffix = ".wat";
    };
    runtimeInputs = [ pkgs.wabt ];
    text = ''
      exec wasm2wat "$@"
    '';
  };

  convertWatToWasm = pkgs.writeShellApplication {
    name = "convert-wat-to-wasm";
    passthru = {
      fromSuffix = ".wat";
      toSuffix = ".wasm";
    };
    runtimeInputs = [ pkgs.wabt ];
    text = ''
      exec wat2wasm "$@" --output=-
    '';
  };

}
