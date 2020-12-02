{ ipfs-cluster }:

ipfs-cluster.overrideAttrs (oldAttrs: rec {
  patches = [ ./ipfs-api-via-unix-socket.patch ];
})
