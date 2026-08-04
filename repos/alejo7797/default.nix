{
  pkgs ? import <nixpkgs> { },
}:

{
  overlays = import ./overlays;
}

// pkgs.lib.makeScope pkgs.newScope (self: {

  pythonOverlay = python-final: _: self.callPackage ./pkgs/python-modules {
    python3Packages = python-final;
  };

  shellScripts = self.callPackage ./pkgs/shell-scripts { };

  inherit (self.shellScripts)
    audio-switch
    round-corners
    ;

  dev-manager-desktop = self.callPackage ./pkgs/webos/dev-manager-desktop { };

  frobby = self.callPackage ./pkgs/math/frobby { };

  gfan_0_8beta = self.callPackage ./pkgs/math/gfan/0_8beta.nix { };

  knotjob = self.callPackage ./pkgs/math/knotjob { };

  knottheory = self.callPackage ./pkgs/math/knottheory { };

  khoca = self.callPackage ./pkgs/math/khoca { };

  macaulay2 = self.callPackage ./pkgs/math/macaulay2 { };

  massey-pari = self.callPackage ./pkgs/math/massey-pari { };

  obsidianPackages = self.callPackage ./pkgs/obsidian { };

  regina-normal = self.callPackage ./pkgs/math/regina-normal { };

  sage = self.callPackage ./pkgs/math/sage { __sage = pkgs.sage; };

  snappy-topology = self.callPackage ./pkgs/math/snappy-topology { __snappy-topology = pkgs.snappy-topology; };

  snarkjs = self.callPackage ./pkgs/zk/snarkjs { };

})
