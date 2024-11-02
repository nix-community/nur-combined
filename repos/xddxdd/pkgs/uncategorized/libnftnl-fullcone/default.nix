{
  libnftnl,
  lib,
  autoreconfHook,
}:
libnftnl.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ autoreconfHook ];
  patches = (old.patches or [ ]) ++ [
    # Adapted from https://raw.githubusercontent.com/wongsyrone/lede-1/master/package/libs/libnftnl/patches/999-01-libnftnl-add-fullcone-expression-support.patch
    ./999-01-libnftnl-add-fullcone-expression-support.patch
  ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
