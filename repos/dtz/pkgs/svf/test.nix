{ runCommand, recurseIntoAttrs, svf, llvm, clang, graphviz, makeFontsConf, freefont_ttf }:


let
  swapbc = runCommand "swapbc" {
    buildInputs = [ llvm clang ];
    hardeningDisable = [ "all" ];
  } ''
    clang -c -emit-llvm ${./test.c} -o swap.bc
    opt -mem2reg swap.bc -o swap.opt
    mkdir -p $out
    mv swap.opt $out/
  '';
  utils = import ./utils.nix {
    inherit runCommand svf graphviz makeFontsConf freefont_ttf;
  };

in with utils; recurseIntoAttrs {
  # inherit analyze_fn;

  swap = analyze_fn "${swapbc}/swap.opt";
}
