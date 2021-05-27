{
  llvmPackagesOverlay = final: prev: {
    llvmPackagesWithGcc10 = let
      gccForLibs = prev.gcc10.cc;
      wrapCCWith = args: prev.wrapCCWith (args // { inherit gccForLibs; });
      llvmPackages = prev.llvmPackages_10.override {
        buildLlvmTools = llvmPackages.tools;
        targetLlvmLibraries = llvmPackages.libraries;
        inherit wrapCCWith gccForLibs;
      };
    in llvmPackages;
  };
}
