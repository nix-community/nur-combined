{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  iptux = callPackage ./iptux { };
  
  ludii = callPackage ./ludii {
    inherit rp;
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  wechat-devtools = callPackage ./wechat-devtools {
    inherit rp;
  };

  xonsh-direnv = callPackage ./xonsh-direnv { };
}