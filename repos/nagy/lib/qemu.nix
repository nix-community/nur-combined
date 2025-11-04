{ pkgs, ... }:

rec {
  makeCompressedQcow2 =
    {
      image,
      qemu-utils ? pkgs.qemu-utils,
    }:
    pkgs.runCommandLocal "${image.name}.qcow2"
      {
        nativeBuildInputs = [ qemu-utils ];
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
