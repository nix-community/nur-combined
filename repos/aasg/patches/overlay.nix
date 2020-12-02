final: prev:

{

  haunt = final.callPackage ./haunt { inherit (prev) haunt; };

  ipfs-cluster = final.callPackage ./ipfs-cluster { inherit (prev) ipfs-cluster; };

}
