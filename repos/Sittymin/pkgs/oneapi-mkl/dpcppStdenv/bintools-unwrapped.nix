{ runCommand
, runtime
,
}:
runCommand "dpcpp-bintools-${runtime.version}" { preferLocalBuild = true; } ''
  mkdir -p $out/bin

  ln -s ${runtime}/bin/compiler/llvm-ar $out/bin/ar
  # ln -s ${runtime}/bin/compiler/llvm-as $out/bin/as
  # ln -s ${runtime}/bin/compiler/llvm-dwp $out/bin/dwp
  ln -s ${runtime}/bin/compiler/llvm-nm $out/bin/nm
  ln -s ${runtime}/bin/compiler/llvm-objcopy $out/bin/objcopy
  # ln -s ${runtime}/bin/compiler/llvm-objdump $out/bin/objdump
  ln -s ${runtime}/bin/compiler/llvm-ranlib $out/bin/ranlib
  # ln -s ${runtime}/bin/compiler/llvm-readelf $out/bin/readelf
  # ln -s ${runtime}/bin/compiler/llvm-size $out/bin/size
  # ln -s ${runtime}/bin/compiler/llvm-strip $out/bin/strip
  ln -s ${runtime}/bin/compiler/lld $out/bin/ld

  ln -s ${runtime}/bin/compiler/llvm-cov $out/bin/cov
  ln -s ${runtime}/bin/compiler/llvm-foreach $out/bin/foreach
  ln -s ${runtime}/bin/compiler/llvm-link $out/bin/link
  ln -s ${runtime}/bin/compiler/llvm-ml $out/bin/ml
  ln -s ${runtime}/bin/compiler/llvm-profgen $out/bin/profgen
  ln -s ${runtime}/bin/compiler/llvm-spirv $out/bin/spirv
  ln -s ${runtime}/bin/compiler/llvm-symbolizer $out/bin/symbolizer
''
