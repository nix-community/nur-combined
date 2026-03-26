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

  knotjob = self.callPackage ./pkgs/math/knotjob { };

  knottheory = self.callPackage ./pkgs/math/knottheory { };

  khoca = self.callPackage ./pkgs/math/khoca { };

  massey-pari = self.callPackage ./pkgs/math/massey-pari { };

  regina-normal = self.callPackage ./pkgs/math/regina-normal { };

  sage = self.callPackage ./pkgs/math/sage { __sage = pkgs.sage; };

  snappy-topology = self.callPackage ./pkgs/math/snappy-topology { };

  snarkjs = self.callPackage ./pkgs/zk/snarkjs { };

})
