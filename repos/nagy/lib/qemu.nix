{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  makeCompressedQcow2 =
    { image }:
    pkgs.runCommandLocal "${image.name}.qcow2"
      {
        nativeBuildInputs = [ pkgs.qemu-utils ];
      }
      ''
        xzcat ${image} > image
        qemu-img convert -O qcow2 -c -o compression_type=zstd image $out
      '';

  writeExpect = pkgs.writers.makeScriptWriter {
    interpreter = "${pkgs.expect}/bin/expect -f";
  };

  writeExpectBin = name: writeExpect "/bin/${name}";

  convertQcowToText = pkgs.writeShellApplication {
    name = "convert-qcow-to-text";
    passthru = {
      fromSuffix = ".qcow2";
      toSuffix = ".txt";
    };
    runtimeInputs = [ pkgs.qemu-utils ];
    text = ''
      exec qemu-img info "$1"
    '';
  };

  convertQcowToJson = pkgs.writeShellApplication {
    name = "convert-qcow-to-json";
    passthru = {
      fromSuffix = ".qcow2";
      toSuffix = ".json";
    };
    runtimeInputs = [ pkgs.qemu-utils ];
    text = ''
      exec qemu-img info --output json "$1"
    '';
  };

  qcow2ToJson =
    { filename }:
    pkgs.runCommandLocal "qcow2-info.json"
      {
        nativeBuildInputs = [ convertQcowToJson ];
      }
      ''
        convert-qcow-to-json ${filename} > $out
      '';

  importQCOW2 = {
    check = lib.hasSuffix ".qcow2";
    __functor = _self: filename:
      lib.importJSON (qcow2ToJson {
        inherit filename;
      });
  };
}
