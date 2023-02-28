{
  nftables,
  libnftnl-fullcone,
  fetchurl,
  ...
}:
(nftables.override {
  libnftnl = libnftnl-fullcone;
})
.overrideAttrs (old: {
  patches =
    (old.patches or [])
    ++ [
      (fetchurl {
        url = "https://raw.githubusercontent.com/wongsyrone/lede-1/master/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch";
        sha256 = "18ganv3jxkslb8vpilkayhzvlp8mgfsxlqcpc07h11vi0md29b7r";
      })
    ];
})
