{
  pkgs,
  lib,
  ...
}:
pkgs.llvmPackages.clang.overrideAttrs (old: {
  pname = "clang-minimal";
  installPhase = old.installPhase + ''
    # 追加删除操作到原始安装流程
    echo "=== Running custom strip phase ==="
    ${lib.concatMapStrings (tool: "rm -f $out/bin/${tool}\n") [
      "addr2line"
      "ar"
      "as"
      "c++"
      "c++filt"
      "cc"
      "cpp"
      "dwp"
      "elfedit"
      "gprof"
      "ld*"
      "nm"
      "objcopy"
      "objdump"
      "ranlib"
      "readelf"
      "size"
      "strings"
      "strip"
    ]}
  '';
})
