{ self }: {
  linode = import ./linode.nix { inherit self; };
  oracle = import ./oracle.nix { inherit self; };
}
