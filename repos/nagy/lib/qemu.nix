{ pkgs, ... }:

rec {
  makeCompressedQcow2 =
    img:
    pkgs.runCommandLocal "${img.name}.qcow2" { } ''
      xzcat ${img} > image
      ${pkgs.qemu-utils}/bin/qemu-img convert -O qcow2 -c -o compression_type=zstd image $out
    '';

  writeExpect = pkgs.writers.makeScriptWriter {
    interpreter = "${pkgs.expect}/bin/expect -f";
  };

  writeExpectBin = name: writeExpect "/bin/${name}";
}
