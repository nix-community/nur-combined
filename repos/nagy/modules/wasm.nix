{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.wasm;
in
{
  options.nagy.wasm = {
    enable = lib.mkEnableOption "wasm config";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wabt
      pkgs.wasmtime
      pkgs.wamr
      # pkgs.wasmer
      # pkgs.wasmedge # broken
    ];

    boot.binfmt.emulatedSystems = [ "wasm32-wasi" ];

    # not fulfilled by above "wasm32-wasi"
    boot.binfmt.registrations.wat = {
      recognitionType = "extension";
      magicOrExtension = "wat";
      interpreter = lib.getExe pkgs.wasmtime;
    };

    programs.git = {
      config = {
        diff = {
          wasm = {
            textconv = "${pkgs.wabt}/bin/wasm2wat";
            binary = true;
          };
        };
      };
    };

    environment.etc.gitattributes = {
      text = lib.mkAfter ''
        *.wasm diff=wasm
      '';
    };
  };
}
