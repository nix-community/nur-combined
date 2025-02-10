{ lib }:
let

  srvOnEihort = [
    "eihort.nyaw.xyz"
    "matrix.nyaw.xyz"
    "photo.nyaw.xyz"
    "s3.nyaw.xyz"
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
        "${builtins.elemAt (lib.splitString "/" value.unique_addr) 0}" = lib.singleton "${name}.nyaw.xyz";
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
