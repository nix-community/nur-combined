{
  pkgs,
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
}
