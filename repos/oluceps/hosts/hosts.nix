{ lib }:
let

  srvOnEihort = map (n: n + ".nyaw.xyz") [
    "matrix"
    "gf"
    "photo"
    "s3"
    "ms"
    "alist"
    "book"
    "scrutiny"
    "seaweedfs"
    "oidc"
    "memos"
    "rqbit"
    "seed"
  ];
  srvOnHastur = [
    "cache.nyaw.xyz"
  ];

  sum = lib.mkMerge [
    (lib.foldlAttrs (
      acc: name: value:
      acc
      // {
        "${lib.getAddrFromCIDR value.unique_addr}" = lib.singleton "${name}.nyaw.xyz";
      }
    ) { } lib.data.node)
    {
      "fdcc::3" = srvOnEihort;
      "fdcc::1" = srvOnHastur;
      "127.0.0.1" = [ "sync.nyaw.xyz" ];
    }
  ];
in
{
  kaambl = sum;
  hastur = sum;
  eihort = sum;
}
