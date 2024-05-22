{
  nftables,
  lib,
  libnftnl-fullcone,
  fetchurl,
  ...
}:
(nftables.override { libnftnl = libnftnl-fullcone; }).overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchurl {
      url = "https://raw.githubusercontent.com/wongsyrone/lede-1/master/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch";
      hash = "sha256-4C/kiaLxxDGRH6V0wQCUk0ZIEKTKADd6KRv8U9lb6fU=";
    })
  ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
