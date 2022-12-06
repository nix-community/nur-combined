{ libnftnl
, autoreconfHook
, fetchurl
, ...
}:

libnftnl.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ autoreconfHook ];
  patches = (old.patches or [ ]) ++ [
    (fetchurl {
      url = "https://raw.githubusercontent.com/wongsyrone/lede-1/master/package/libs/libnftnl/patches/999-01-libnftnl-add-fullcone-expression-support.patch";
      sha256 = "0n4b4kv19m2l1ppz8qpksihphbdkv0d17rz4wsnsnznp08cd87rj";
    })
  ];
})
