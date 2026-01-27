{ pkgs }: {
  pkgs = {
    riscVivid = pkgs.callPackage ./pkgs/riscVivid { };
  };
}
