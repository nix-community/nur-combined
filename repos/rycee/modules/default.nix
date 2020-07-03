{
  containers-docker-support = ./containers-docker-support.nix;

  home-manager = { lib, ... }: {
    imports = let hm = import ../pkgs/home-manager/src.nix { inherit lib; };
    in [ "${hm}/nixos" ];
  };
}
