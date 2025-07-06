{ lib }:
let

  srvOnEihort = map (n: n + ".nyaw.xyz") [
    "matrix"
    "photo"
    "s3"
    "ms"
    "alist"
    "book"
    "scrutiny"
    "seaweedfs"
    "oidc"
    "memos"
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
    }
  ];
in
{
  kaambl = sum;
  hastur = sum;
  eihort = sum // {
    "127.0.0.1" = srvOnEihort;
  };
}
