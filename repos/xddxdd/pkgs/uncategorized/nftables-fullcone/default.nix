{
  nftables,
  lib,
  libnftnl-fullcone,
}:
(nftables.override { libnftnl = libnftnl-fullcone; }).overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # Adapted from https://raw.githubusercontent.com/wongsyrone/lede-1/master/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch
    ./999-01-nftables-add-fullcone-expression-support.patch
  ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
