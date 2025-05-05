{ lib }:
let

  srvOnEihort = [
    "matrix.nyaw.xyz"
    "photo.nyaw.xyz"
    "s3.nyaw.xyz"
    "ms.nyaw.xyz"
    "alist.nyaw.xyz"
    "book.nyaw.xyz"
    "scrutiny.nyaw.xyz"
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
