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
    "linkwarden.nyaw.xyz"
  ];
  srvOnHastur = [
    "cache.nyaw.xyz"
  ];

  nodes = (builtins.fromTOML (builtins.readFile ../hosts/sum.toml)).node;

  sum = lib.mkMerge [
    (lib.foldlAttrs (
      acc: name: value:
      acc
      // {
        "${lib.getAddrFromCIDR value.unique_addr}" = lib.singleton "${name}.nyaw.xyz";
      }
    ) { } nodes)
    {
      "fdcc::3" = srvOnEihort;
      "fdcc::1" = srvOnHastur;
    }
  ];
in
{
  kaambl = {
  } // sum;
  hastur = {
  } // sum;
  eihort = {
  } // sum;
}
